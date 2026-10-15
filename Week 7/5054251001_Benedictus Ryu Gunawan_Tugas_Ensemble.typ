// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Laporan Klasifikasi Fraud dengan Ensemble Method dan Class Imbalance",
  author: ("Benedictus Ryu Gunawan", "5054251001"),
)
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  numbering: "1",
  number-align: center,
)
#set text(font: "New Computer Modern", size: 11pt, lang: "id")
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1.")
#set list(indent: 1.2em, body-indent: 0.5em, spacing: 0.4em)




// ============================================
// HALAMAN JUDUL
// ============================================
#align(center)[
  #v(2em)
  #text(size: 18pt, weight: "bold")[TUGAS - WEEK 7]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN KLASIFIKASI FRAUD KARTU KREDIT DENGAN ENSEMBLE METHOD DAN CLASS IMBALANCE]
  #v(3em)
  #table(
    columns: (auto, 1fr), align: (left, left), inset: 6pt, stroke: none,
    [Nama], [: Benedictus Ryu Gunawan],
    [NRP], [: 5054251001],
    [Kelas], [: N],
    [Mata Kuliah], [: Penambangan Data],
    [Dosen], [: Dini Adni Navastara, S.Kom., M.Sc. dan Aldinata Rizky Revanda, S.Kom., M.Kom.],
  )
  #v(1fr)
  #text(weight: "bold")[DEPARTEMEN INFORMATIKA]

  INSTITUT TEKNOLOGI SEPULUH NOPEMBER

  Surabaya
  2026
]
#pagebreak()
#outline(title: [Daftar Isi], indent: auto)
#pagebreak()

= Pendahuluan

== Latar Belakang

Deteksi penipuan kartu kredit adalah masalah klasifikasi dengan ketidakseimbangan kelas yang ekstrem: transaksi penipuan (fraud) jauh lebih sedikit daripada transaksi normal, tetapi biaya kegagalan mendeteksinya sangat besar. Dataset Credit Card Fraud Detection dari Kaggle (https://www.kaggle.com/mlg-ulb/creditcardfraud) adalah contoh klasik kondisi ini, dengan hanya 0,17\% transaksi berlabel fraud dari 284.807 transaksi selama dua hari pada September 2013.

Pada data seperti ini, model yang mengoptimalkan akurasi akan cenderung memprediksi semua transaksi sebagai normal dan tetap terlihat bagus. Karena itu praktikum ini menekankan dua hal: (1) perbandingan konsep ensemble - bagging (Random Forest), boosting (XGBoost, HistGradientBoosting), balanced ensemble (BalancedRandomForest), serta heterogeneous ensemble (Voting dan Stacking) - dan (2) penanganan imbalance yang benar - resampling hanya pada data latih - beserta evaluasi yang fokus pada kelas minoritas.

== Tujuan

Tujuan praktikum ini adalah:

1. Memahami penerapan berbagai ensemble method (bagging, boosting, voting, stacking) dalam klasifikasi data tidak seimbang.
2. Mengatasi class imbalance dengan oversampling SMOTE, cost-sensitive learning (`class_weight`, `scale_pos_weight`), dan balanced ensemble.
3. Mengevaluasi model dengan precision, recall, F1-score, dan AUC-ROC pada kelas fraud serta confusion matrix, dan menjelaskan mengapa accuracy saja tidak cukup.

Alur kerja mengikuti notebook `5054251001_Benedictus Ryu Gunawan_Tugas_Ensemble.ipynb`. Seluruh gambar pada laporan ini dihasilkan oleh notebook tersebut dan tersimpan pada folder `output/`.

= Deskripsi Dataset

Dataset `creditcard.csv` terdiri dari 284.807 baris dan 31 kolom: 30 fitur dan 1 target. Tidak ditemukan nilai hilang pada seluruh kolom.

#figure(
  table(
    columns: (2fr, 2fr, 5fr),
    stroke: 0.5pt,
    table.header(
      [*Fitur*],
      [*Tipe*],
      [*Deskripsi*]
    ),
    [Time], [Numerik kontinu], [Detik sejak transaksi pertama dalam dataset],
    [V1 -- V28], [Numerik kontinu], [Komponen hasil PCA (anonimisasi untuk kerahasiaan)],
    [Amount], [Numerik kontinu], [Nominal transaksi dalam Euro/dolar],
    [Class], [Biner], [0 = normal, 1 = fraud (target)],
  ),
  caption: [Struktur fitur dataset Credit Card Fraud Detection]
)

Fitur `V1` sampai `V28` sudah terstandardisasi (mean mendekati nol) karena merupakan keluaran PCA, sedangkan `Time` dan `Amount` memiliki skala asli sehingga perlu standardisasi sebelum SMOTE yang berbasis jarak Euclidean. Korelasi linear tiap fitur terhadap `Class` semuanya lemah (|r| < 0,35), sehingga model non-linear ensemble lebih sesuai daripada model linear.

== Distribusi Kelas Awal

#figure(
  table(
    columns: 3,
    align: center,
    stroke: 0.5pt,
    table.header(
      [*Kelas*],
      [*Jumlah*],
      [*Persentase*]
    ),
    [0 = normal], [284.315], [99,83\%],
    [1 = fraud], [492], [0,17\%],
  ),
  caption: [Distribusi kelas awal pada seluruh dataset]
)

Rasio imbalance adalah sekitar 578 : 1. Median `Amount` pada transaksi normal adalah 22,00 sedangkan pada fraud hanya 9,25 - fraud cenderung bernominal kecil untuk menghindari deteksi, tetapi distribusinya tumpang tindih sehingga `Amount` saja tidak cukup sebagai pembeda.

#figure(
  image("output/class_distribution.png", width: 100%),
  caption: [Distribusi kelas awal. Batang fraud hampir tidak terlihat pada skala linear; fraud hanya 492 dari 284.807 transaksi.],
) <fig-class>

#figure(
  image("output/amount_time_by_class.png", width: 100%),
  caption: [Perbandingan Amount dan Time per kelas. Histogram Amount memakai sumbu-y log agar ekor fraud tetap terlihat; fraud rate per bin waktu menunjukkan variasi temporal.],
) <fig-amount-time>

#figure(
  image("output/corr_with_target.png", width: 100%),
  caption: [Korelasi tiap fitur dengan target Class. Tidak ada korelasi linear kuat, mendukung pemilihan model ensemble non-linear.],
) <fig-corr>

= Metode

== Train–Test Split 80:20 dengan Stratify

Dataset dibagi 80\% latih dan 20\% uji dengan `stratify=y` dan `random_state=42`, sehingga proporsi fraud 0,17\% terjaga di kedua belah. Tanpa stratifikasi, sampel uji dapat kebetulan tidak mengandung fraud sama sekali.

#figure(
  table(
    columns: 4,
    align: center,
    stroke: 0.5pt,
    table.header(
      [*Subset*],
      [*Normal*],
      [*Fraud*],
      [*Total*]
    ),
    [Latih (80\%)], [227.451], [394], [227.845],
    [Uji (20\%)], [56.864], [98], [56.962],
  ),
  caption: [Komposisi train dan test setelah stratified split]
)

Hanya `Time` dan `Amount` yang di-`StandardScaler`. Scaler di-fit pada data latih lalu dipakai untuk transform latih dan uji agar tidak terjadi kebocoran data (data leakage).

#figure(
  image("output/scaling_amount.png", width: 100%),
  caption: [Distribusi Amount sebelum dan sesudah standardisasi pada data latih.],
) <fig-scaling>

== Penanganan Class Imbalance

Dipilih **SMOTE** (Synthetic Minority Over-sampling Technique): untuk tiap sampel fraud dicari k-tetangga fraud terdekat, lalu dibuat titik sintetis pada segmen garis antaranya. SMOTE hanya diterapkan pada data latih; data uji dibiarkan pada distribusi asli agar evaluasi jujur. Undersampling tidak dipilih sebagai pendekatan utama karena akan membuang lebih dari 99\% data normal yang informatif. Sebagai pembanding dipakai **cost-sensitive learning** (`class_weight='balanced'` pada RF/HGB/LogReg dan `scale_pos_weight=578` pada XGBoost) tanpa resampling, serta **balanced ensemble** yang melakukan undersampling internal per pohon.

#figure(
  image("output/smote_comparison.png", width: 100%),
  caption: [Jumlah sampel latih sebelum dan sesudah SMOTE: dari 227.451 : 394 menjadi 227.451 : 227.451 (total 454.902 baris).],
) <fig-smote>

== Model Ensemble (8 Varian)

Dibandingkan empat konsep ensemble:

- **Bagging**: Random Forest (bootstrap + random subspace), 100 pohon. Varian A–C.
- **Boosting**: XGBoost (`n_estimators=200, max_depth=6, lr=0,05`) dan HistGradientBoosting sebagai base voter. Pohon dibangun sekuensial memperbaiki residual. Varian D–E.
- **Balanced ensemble**: BalancedRandomForest - tiap bootstrap diundersampling agar tiap pohon melihat kelas seimbang. Varian F.
- **Heterogeneous**: Voting soft (rata-rata probabilitas RF + XGB + HGB-balanced) dan Stacking (base RF + XGB, meta LogisticRegression balanced dengan CV=3). Varian G–H.

#figure(
  table(
    columns: (2fr, 4fr, 4fr),
    align: left,
    stroke: 0.5pt,
    table.header(
      [*Model*],
      [*Konsep*],
      [*Handling imbalance*]
    ),
    [A. RF baseline], [Bagging], [Tanpa handling],
    [B. RF + SMOTE], [Bagging + oversampling], [SMOTE pada train],
    [C. RF balanced], [Bagging cost-sensitive], [`class_weight='balanced'`],
    [D. XGBoost], [Boosting], [Tanpa handling],
    [E. XGB balanced], [Boosting cost-sensitive], [`scale_pos_weight=578`],
    [F. BalancedRF], [Balanced bagging], [Undersampling per pohon],
    [G. Voting soft], [Heterogeneous voting], [Rata-rata RF+XGB+HGB-bal],
    [H. Stacking], [Heterogeneous stacking], [Meta-LogReg balanced, CV=3],
  ),
  caption: [Delapan varian ensemble yang dibandingkan]
)

Waktu latih pada mesin praktikum: A 19,6 dtk, B 33,5 dtk, C 7,6 dtk, D 8,1 dtk, E 8,6 dtk, F 1,8 dtk, G 23,1 dtk, H 117,0 dtk (Stacking mahal karena CV 3x2 base learners + meta).

= Hasil dan Evaluasi

Metrik dihitung pada data uji asli (56.962 transaksi). Fokus penilaian adalah kelas fraud.

#figure(
  table(
    columns: 7,
    align: center,
    stroke: 0.5pt,
    table.header(
      [*Model*],
      [*Acc*],
      [*Prec*],
      [*Rec*],
      [*F1*],
      [*ROC*],
      [*PR*]
    ),
    [A. RF base], [0,9996], [0,9412], [0,8163], [0,8743], [0,9630], [0,8734],
    [B. RF SMOTE], [0,9995], [0,8454], [0,8367], [0,8410], [0,9731], [0,8747],
    [C. RF bal], [0,9995], [0,9059], [0,7857], [0,8415], [0,9573], [0,8629],
    [D. XGB], [0,9996], [0,9419], [0,8265], [0,8804], [0,9730], [0,8731],
    [E. XGB bal], [0,9993], [0,7545], [0,8469], [0,7981], [0,9823], [0,8654],
    [F. BalRF], [0,9891], [0,1246], [0,8878], [0,2186], [0,9775], [0,7654],
    [G. Voting], [0,9996], [0,9011], [0,8367], [0,8677], [0,9665], [0,8769],
    [H. Stack], [0,9983], [0,5087], [0,8980], [0,6494], [0,9806], [0,8451],
  ),
  caption: [Ringkasan metrik pada data uji. Precision, recall, dan F1 adalah untuk kelas fraud; ROC = ROC-AUC, PR = PR-AUC.]
)

#figure(
  image("output/metrics_bar.png", width: 100%),
  caption: [Perbandingan precision, recall, F1 (fraud) dan ROC-AUC untuk 8 model. XGBoost unggul F1, Stacking/XGB-balanced unggul recall dan AUC, BalancedRF jatuh precision-nya.],
) <fig-bar>

#figure(
  image("output/confusion_matrices.png", width: 100%),
  caption: [Confusion matrix 8 model pada data uji. A: TN=56.859 FP=5 FN=18 TP=80; B: 56.849/15/16/82; C: 56.856/8/21/77; D: 56.859/5/17/81; E: 56.837/27/15/83; F: 56.253/611/11/87; G: 56.855/9/16/82; H: 56.779/85/10/88.],
) <fig-cm>

#figure(
  image("output/roc_pr_curves.png", width: 100%),
  caption: [Kurva ROC (kiri) dan Precision-Recall (kanan) untuk 8 model. Kurva PR lebih informatif untuk imbalance; XGB-balanced dan Stacking memimpin AUC.],
) <fig-roc-pr>

== Analisis Perbandingan

**Bagging (A–C)**: Baseline (A) paling presisi (0,94) dengan F1 0,87 dan hanya 5 FP tetapi 18 FN. SMOTE (B) menaikkan recall ke 0,84 dengan biaya 10 FP ekstra (precision 0,85). RF balanced (C) di tengah (precision 0,91, recall 0,79).

**Boosting (D–E)**: XGBoost (D) menjadi juara F1 (0,8804) dengan precision 0,94 dan recall 0,83 - boosting sekuensial menangkap interaksi yang lolos dari bagging. XGB balanced (E) mengorbankan precision (0,75) demi recall 0,85 dan ROC-AUC tertinggi kedua (0,9823).

**Balanced ensemble (F)**: BalancedRF mencapai recall 0,89 dan AUC 0,98 tetapi precision ambruk ke 0,12 (611 FP): tiap pohon melihat subsampel seimbang sehingga sangat sensitif tetapi banyak alarm palsu. Cocok bila missing fraud sangat mahal, tidak cocok bila biaya investigasi tinggi.

**Heterogeneous (G–H)**: Voting soft (G) stabil dengan F1 0,87, recall 0,84, precision 0,90 dan PR-AUC terbaik (0,8769) - rata-rata probabilitas meredam varians single model. Stacking (H) dengan meta-LogReg mencapai ROC-AUC tertinggi (0,9806) dan recall 0,90 (88/98 fraud tertangkap) tetapi precision hanya 0,51: meta-learner berani menaikkan recall karena belajar dari ketidaksepakatan base learners.

Akurasi semua model 0,989–0,999 yang nyaris identik - bukti akurasi tidak diskriminatif; yang membedakan hanyalah selisih FP/FN pada 98 fraud uji.

Fitur terpenting XGBoost didominasi komponen PCA `V14`, `V17`, `V12`, dan `V10`, sedangkan `Amount` dan `Time` berada di luar 10 besar - konsisten dengan korelasi linear yang lemah.

#figure(
  image("output/feature_importance.png", width: 80%),
  caption: [Lima belas fitur terpenting menurut XGBoost (gain/importance).],
) <fig-importance>

== Mengapa Accuracy Saja Tidak Cukup

Model naif yang selalu memprediksi normal (DummyClassifier `most_frequent`) sudah mencapai akurasi 0,9983 (56.864/56.962) tetapi recall, precision, dan F1 fraud semuanya nol - tidak satu pun fraud tertangkap. Akurasi didominasi 56.864 transaksi normal, sehingga perbedaan belasan kesalahan fraud hampir tidak mengubah akurasi namun sangat mengubah recall dan precision fraud. Kurva ROC pun dapat terlihat optimistis karena false positive rate kecil akibat TN yang besar; kurva Precision-Recall dan confusion matrix jauh lebih jujur untuk data ini.

= Kesimpulan

Dataset memiliki imbalance ekstrem 578 : 1 (492 fraud dari 284.807 transaksi). Penanganan yang benar adalah stratified split 80:20, standardisasi `Time`/`Amount` dengan fit hanya pada latih, dan SMOTE hanya pada latih sehingga uji tetap berdistribusi asli. Perbandingan delapan ensemble menunjukkan: F1 terbaik XGBoost (0,88), precision terbaik RF baseline/XGBoost (~0,94), recall terbaik Stacking (0,90), ROC-AUC terbaik XGB balanced (0,9823) dan Stacking (0,9806), serta Voting paling seimbang (F1 0,87, PR-AUC 0,877). Akurasi semuanya ~0,99 sehingga tidak dapat dipakai memilih model. Rekomendasi praktis: gunakan XGBoost atau Voting untuk F1 seimbang, Stacking atau BalancedRF bila prioritas menangkap fraud, RF baseline bila prioritas meminimalkan alarm palsu. Seluruh implementasi, angka, dan gambar dapat direproduksi dari notebook pendamping.
