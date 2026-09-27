// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Laporan Hasil Preprocessing House Advanced Regression",
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
  #text(size: 18pt, weight: "bold")[TUGAS - WEEK 4]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN HASIL PREPROCESSING HOUSE ADVANCED REGRESSION]
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

Laporan ini menyusun hasil exploratory data analysis dan preprocessing pada dataset House Prices Advanced Regression Techniques. Fokus analisis adalah memahami karakteristik rumah di Ames, memetakan kualitas data, membersihkan nilai hilang, menilai outlier secara kontekstual, menyeragamkan skala dan representasi kategori, serta mengurangi dimensi yang saling berkorelasi tanpa membuang informasi penting. Target analisis adalah SalePrice yaitu harga jual rumah dalam dolar.

Dataset awal yang dianalisis memiliki 1460 baris dan 80 kolom setelah kolom identitas dijadikan index. Artinya terdapat 79 prediktor dan satu target. Prediktor mencakup kelompok lot dan lahan, lokasi dan zonasi, kualitas dan kondisi bangunan, tahun pembangunan dan renovasi, basement, lantai dan luas hunian, kamar mandi dan kamar tidur, dapur, perapian, garasi, teras dan dek, kolam dan pagar, hingga kondisi penjualan. Target tidak memiliki nilai hilang sehingga seluruh baris dapat dipakai untuk pemodelan.

Alur kerja yang dibahas dalam laporan ini mengikuti struktur penugasan. Bagian dua membahas pembersihan data. Bagian tiga membahas deteksi dan penanganan outlier. Bagian empat membahas transformasi data. Bagian lima membahas reduksi dimensi. Seluruh visualisasi yang dirujuk berasal dari notebook analisis.

== Gambaran umum hasil EDA

EDA menunjukkan pasar didominasi rumah menengah dengan sedikit rumah mewah yang menjadi ekor kanan distribusi. Harga terkonsentrasi pada rentang 120 ribu sampai 250 ribu dengan ekor memanjang ke atas 700 ribu. Pola ini berulang pada fitur luas dan kualitas. Fitur yang paling berkaitan dengan harga adalah kualitas material dan finishing serta total luas hunian. Fitur yang jarang dimiliki seperti kolam, fitur miscellaneous, dan teras tiga musim memiliki distribusi menumpuk di nol dan hubungan yang lemah dengan harga. Pola nilai hilang bersifat struktural dan berkelompok, bukan acak. Temuan ini menjadi dasar keputusan imputasi dan penanganan outlier pada bagian berikutnya.

== Distribusi atribut numerik

Terdapat 37 atribut numerik termasuk target. Visualisasi histogram dengan kurva kepadatan menunjukkan tiga pola utama.

Pertama, distribusi miring ke kanan untuk harga dan luas. SalePrice memiliki kemiringan sekitar 1.88. LotArea memiliki rentang 1300 sampai 215245 dengan kemiringan awal sekitar 12.20. GrLivArea, TotalBsmtSF, First Floor SF, MasVnrArea, WoodDeckSF, dan OpenPorchSF memiliki pola serupa dengan konsentrasi di nilai kecil dan menengah serta ekor di nilai besar.

Kedua, distribusi zero inflated untuk fasilitas langka. PoolArea, MiscVal, Three Season Porch, LowQualFinSF, BsmtFinSF2, ScreenPorch, dan EnclosedPorch menumpuk di nol dengan sedikit nilai besar di kanan. Contoh MiscVal mencapai 15500 padahal mediannya nol. PoolArea mencapai 738. ScreenPorch mencapai 480. Pola ini wajar karena tidak semua rumah memiliki fasilitas tersebut.

Ketiga, distribusi tahun yang miring ke kiri secara ringan. YearBuilt, YearRemodAdd, dan GarageYrBlt memiliki banyak rumah relatif baru dan sedikit rumah sangat tua. Kemiringannya berada pada kisaran minus 0.50 sampai minus 0.67. Atribut ordinal seperti OverallQual, FullBath, BedroomAbvGr, Fireplaces, dan GarageCars relatif simetris kecuali KitchenAbvGr yang miring karena hampir semua rumah memiliki satu dapur.

#figure(
  image("../output/figures/cell17_out1_fig2.png", width: 100%),
  caption: [Distribusi 37 atribut numerik. Terlihat ekor kanan pada harga dan luas serta penumpukan nol pada fasilitas langka.],
) <fig-hist>

== Korelasi awal dengan target

Heatmap korelasi berukuran 37 kali 37 memberikan gambaran hubungan antar atribut numerik dan hubungan masing masing atribut dengan SalePrice.

Hubungan sangat kuat di atas 0.60 ditemukan pada OverallQual sekitar 0.79, GrLivArea sekitar 0.70, GarageCars sekitar 0.64, GarageArea sekitar 0.62, TotalBsmtSF sekitar 0.61, dan First Floor SF sekitar 0.60. Hubungan kuat pada rentang 0.50 sampai 0.60 ditemukan pada FullBath, total ruangan di atas tanah, YearBuilt, dan YearRemodAdd. Hubungan sedang pada rentang 0.30 sampai 0.50 ditemukan pada MasVnrArea, Fireplaces, GarageYrBlt, BsmtFinSF1, LotFrontage, WoodDeckSF, Second Floor SF, dan OpenPorchSF.

Hubungan lemah di bawah 0.30 ditemukan pada HalfBath, LotArea, dan atribut teras lain. Hubungan mendekati nol atau negatif lemah ditemukan pada MiscVal, LowQualFinSF, YrSold, OverallCond, MSSubClass, EnclosedPorch, dan KitchenAbvGr. Pesan utama EDA adalah kualitas dan luas merupakan penentu harga, sedangkan fasilitas langka dan atribut administratif tahun terjual memiliki daya beda yang kecil.

#figure(
  image("../output/figures/cell20_out1_fig4.png", width: 100%),
  caption: [Heatmap korelasi antar atribut numerik. Warna hangat menandakan korelasi positif kuat, warna dingin menandakan korelasi lemah atau negatif.],
) <fig-corr>

== Pola nilai hilang sebagai temuan EDA

Diagram kelengkapan per kolom menunjukkan lima kolom hampir kosong total yaitu PoolQC, MiscFeature, Alley, Fence, dan MasVnrType. Diagram matriks dan peta panas korelasi missing menunjukkan missing terjadi bersamaan dalam blok. Blok garasi hilang bersamaan pada 81 baris untuk tipe garasi, tahun garasi, finishing, kualitas, dan kondisi. Blok basement hilang bersamaan pada 37 sampai 38 baris untuk kualitas basement, kondisi, exposure, dan tipe finishing. Pola berkelompok ini menandakan ketiadaan objek fisik, bukan kesalahan pencatatan acak. Rumah tanpa garasi memang tidak memiliki tahun garasi. Rumah tanpa basement memang tidak memiliki kualitas basement. Rumah tanpa perapian memang tidak memiliki kualitas perapian.

#figure(
  image("../output/figures/cell07_out1_fig0.png", width: 100%),
  caption: [Tingkat kelengkapan tiap kolom. Lima kolom di sisi kanan hampir seluruhnya hilang.],
) <fig-missing-bar>

#figure(
  image("../output/figures/cell11_out2_fig1.png", width: 100%),
  caption: [Peta panas dan matriks pola missing. Blok garasi dan blok basement hilang secara bersamaan.],
) <fig-missing-pattern>

= Pembersihan Data

== Periksa jumlah nilai hilang pada setiap atribut

Pemeriksaan dilakukan untuk seluruh atribut dengan menghitung jumlah dan persentase baris yang hilang. Dari 1460 baris, ditemukan 19 atribut yang memiliki nilai hilang. Sisanya sebanyak 61 atribut lengkap termasuk target SalePrice.

Hasil pemeriksaan dari persentase terbesar ke terkecil adalah PoolQC 1453 baris atau 99.52 persen, MiscFeature 1406 baris atau 96.30 persen, Alley 1369 baris atau 93.76 persen, Fence 1179 baris atau 80.75 persen, MasVnrType 872 baris atau 59.72 persen, FireplaceQu 690 baris atau 47.26 persen, LotFrontage 259 baris atau 17.73 persen, GarageType 81 baris atau 5.54 persen, GarageYrBlt 81 baris, GarageFinish 81 baris, GarageQual 81 baris, GarageCond 81 baris, BsmtExposure 38 baris atau 2.60 persen, BsmtFinType2 38 baris, BsmtQual 37 baris atau 2.53 persen, BsmtCond 37 baris, BsmtFinType1 37 baris, MasVnrArea 8 baris atau 0.54 persen, dan Electrical 1 baris atau 0.06 persen.

Tabel ini penting karena menentukan perlakuan yang berbeda untuk tiap kelompok. Kelompok di atas 50 persen diperlakukan sebagai penghapusan kolom. Kelompok di bawah 50 persen diperlakukan sebagai imputasi dengan makna domain yang tepat.

== Hapus kolom dengan proporsi nilai hilang lebih dari 50 persen

Lima kolom dengan missing di atas 50 persen dihapus yaitu Alley, MasVnrType, PoolQC, Fence, dan MiscFeature. Setelah penghapusan, dimensi menjadi 1460 baris kali 75 kolom.

Alasan penghapusan adalah sebagai berikut. Pertama, mayoritas informasi sudah hilang sehingga imputasi akan menciptakan data buatan yang mendominasi kolom. Contoh PoolQC hanya memiliki 7 data valid dari 1460 baris. Mengisi 1453 baris sisanya dengan satu nilai akan menyesatkan model. Kedua, kelima atribut menandakan fasilitas langka. Hanya 54 rumah yang memiliki MiscFeature. Hanya sebagian kecil yang memiliki Alley dan Fence yang tercatat. Mempertahankannya hanya menambah dimensi tanpa daya prediksi yang stabil. Ketiga, penghapusan membuat analisis berikutnya lebih andal karena tidak ada lagi kolom dengan missing ekstrem.

== Tangani nilai hilang sisa

Sisa 14 atribut dengan missing di bawah 50 persen ditangani dengan dua strategi sesuai makna datanya. Tujuannya adalah mencapai nol missing tanpa mengubah makna faktual.

Strategi pertama adalah pengisian kategori Tidak Ada untuk 11 atribut kategoris yaitu BsmtCond, BsmtExposure, BsmtFinType1, BsmtFinType2, BsmtQual, Electrical, GarageCond, GarageFinish, GarageQual, FireplaceQu, dan GarageType. Jumlah yang diisi mengikuti hasil pemeriksaan yaitu FireplaceQu 690 baris, lima atribut garasi masing masing 81 baris, BsmtExposure dan BsmtFinType2 masing masing 38 baris, BsmtQual BsmtCond dan BsmtFinType1 masing masing 37 baris, serta Electrical 1 baris.

Alasan pemilihan kategori Tidak Ada adalah kesesuaian domain. Nilai hilang di sini berarti objeknya memang tidak ada. Rumah tanpa perapian tidak memiliki kualitas perapian. Rumah tanpa garasi tidak memiliki tipe garasi. Rumah tanpa basement tidak memiliki kualitas basement. Jika diisi dengan nilai yang paling sering muncul seperti TA atau Attchd, maka model akan mengira rumah tersebut memiliki fasilitas padahal tidak ada. Kategori Tidak Ada justru menjadi informasi yang berguna karena model dapat mempelajari bahwa ketiadaan perapian atau garasi berkaitan dengan tingkat harga tertentu.

Strategi kedua adalah pengisian nilai tengah untuk 3 atribut numerik yaitu MasVnrArea, GarageYrBlt, dan LotFrontage. Jumlah yang diisi adalah LotFrontage 259 baris, MasVnrArea 8 baris, dan GarageYrBlt 81 baris. Alasan pemilihan nilai tengah adalah ketahanan terhadap kemiringan. LotFrontage dan MasVnrArea memiliki ekor kanan sehingga rata rata akan tertarik ke atas. Nilai tengah menjaga pusat distribusi tetap representatif. Untuk tahun garasi, nilai tengah juga lebih stabil dan tidak menghasilkan tahun pecahan yang ekstrem.

Setelah kedua strategi diterapkan, pemeriksaan ulang menunjukkan tidak ada lagi nilai hilang pada seluruh 75 kolom. Data siap untuk analisis outlier dan transformasi.

= Deteksi dan Penanganan Outlier

== Gunakan boxplot untuk mendeteksi outlier pada atribut numerik

Deteksi dilakukan pada 37 atribut numerik dengan boxplot per atribut dan didukung histogram. Boxplot menampilkan median, kotak interkuartil, whisker, dan titik di luar whisker sebagai kandidat outlier.

Temuan boxplot sejalan dengan EDA distribusi. SalePrice sendiri memiliki titik jauh di kanan atas di atas 600 ribu. LotArea memiliki satu titik ekstrem 215245 yang jauh dari kotak utama yang umumnya di bawah 15000. MiscVal mencapai 15500. PoolArea mencapai 738. Three Season Porch mencapai 508. LowQualFinSF mencapai 572. EnclosedPorch mencapai 552. BsmtFinSF2 mencapai 1474. ScreenPorch mencapai 480. Atribut luas seperti GrLivArea, TotalBsmtSF, First Floor SF, GarageArea, dan MasVnrArea memiliki ekor kanan moderat. Atribut ordinal terbatas seperti OverallQual, OverallCond, FullBath, dan BedroomAbvGr hampir tidak memiliki outlier ekstrem.

#figure(
  image("../output/figures/cell18_out0_fig3.png", width: 100%),
  caption: [Boxplot 37 atribut numerik. Titik di luar whisker menandakan kandidat outlier, terutama pada luas lahan, fasilitas langka, dan harga.],
) <fig-boxplot>

== Tentukan apakah outlier dihapus atau disesuaikan beserta alasannya

Keputusan yang diambil adalah outlier tidak dihapus barisnya, melainkan disesuaikan melalui pembatasan rentang dan transformasi logaritmik. Alasan keputusan ini adalah sebagai berikut.

Pertama, pertimbangan domain perumahan mewah. Pola outlier pada fitur luas dan kualitas mengikuti pola outlier pada SalePrice. Rumah dengan luas sangat besar atau kualitas 10 memang wajar berharga sangat tinggi. Contoh rumah dengan kualitas tinggi yang dibangun pada tahun muda tetap terjual mahal. Menghapus baris tersebut berarti membuang segmen pasar mewah yang justru penting untuk diprediksi.

Kedua, pertimbangan perbandingan kemiringan dan korelasi. Atribut dengan kemiringan di atas 3 justru cenderung memiliki korelasi rendah dengan target. MiscVal memiliki kemiringan sekitar 24.47 tetapi korelasi mendekati nol. PoolArea memiliki kemiringan sekitar 14.82 tetapi korelasi hanya sekitar 0.09. LotArea memiliki kemiringan sekitar 12.20 tetapi korelasi hanya sekitar 0.26. Artinya nilai ekstrem tersebut lebih bersifat ekor noise daripada sinyal pembeda harga utama. Karena itu tepat untuk dijinakkan, bukan dihapus.

Ketiga, pertimbangan ukuran sampel. Mempertahankan 1460 baris menjaga stabilitas estimasi untuk regresi dan analisis komponen utama. Penghapusan kaku berbasis rentang interkuartil akan menghilangkan banyak rumah unik dan membuat model bias ke rumah menengah saja.

Penanganan konkret dilakukan pada 10 atribut dengan kemiringan absolut di atas 3 yaitu Three Season Porch, BsmtFinSF2, BsmtHalfBath, EnclosedPorch, KitchenAbvGr, LotArea, LowQualFinSF, MiscVal, PoolArea, dan ScreenPorch. Rentang sebelum penanganan misalnya LotArea 1300 sampai 215245, MiscVal 0 sampai 15500, dan BsmtFinSF2 0 sampai 1474. Tidak ditemukan nilai negatif sehingga transformasi logaritmik dengan penambahan satu sudah memadai.

Tahap pertama adalah pembatasan pada kuantil 1 persen bawah dan 99 persen atas agar nilai paling ekstrem tidak mendominasi. Tahap kedua adalah transformasi logaritmik untuk memampatkan ekor kanan. Hasilnya LotArea membaik dari sekitar 12.20 menjadi sekitar minus 0.13 sehingga mendekati simetris. EnclosedPorch membaik dari sekitar 3.08 menjadi sekitar 2.11. BsmtFinSF2 membaik dari sekitar 4.25 menjadi sekitar 2.52. MiscVal turun besar dari sekitar 24.47 menjadi sekitar 5.17 tetapi masih tinggi karena penumpukan nol yang ekstrem. PoolArea hampir tetap karena terlalu banyak nol. Three Season Porch dan LowQualFinSF masih tinggi karena masalah utamanya adalah distribusi menumpuk di nol, bukan satu outlier tunggal.

Kesimpulan penanganan adalah cukup baik dan proporsional. Atribut yang semula ekstrem menjadi lebih terkendali, sedangkan atribut yang memang zero inflated tetap dibiarkan memiliki kemiringan sisa yang wajar. Hal ini lebih aman dibanding menghapus data atau memaksa seluruh distribusi menjadi normal.

= Transformasi Data

== Lakukan normalisasi atau standarisasi atribut

Seluruh 37 atribut numerik diseragamkan ke skor z dengan rata rata nol dan simpangan baku satu. Tujuannya adalah menyamakan skala agar atribut besar tidak mendominasi analisis.

Kebutuhan standarisasi sangat jelas karena perbedaan skala sangat ekstrem. LotArea berada pada orde ribuan sampai ratusan ribu. OverallQual hanya berada pada rentang 1 sampai 10. Tanpa standarisasi, analisis jarak dan analisis komponen utama akan didominasi LotArea dan GrLivArea. Setelah standarisasi, contoh rumah pertama memiliki nilai terstandar sekitar 0.07 untuk MSSubClass, minus 0.22 untuk LotFrontage, minus 0.13 untuk LotArea, 0.65 untuk OverallQual, dan 1.05 untuk YearBuilt. Rumah kedua memiliki OverallCond sekitar 2.17 yang menandakan kondisi jauh di atas rata rata. Rumah tua dari tahun 1915 memiliki YearBuilt sekitar minus 1.86 yang menandakan jauh di bawah rata rata.

Standarisasi menjaga outlier yang sudah dijinakkan tetap proporsional dalam satuan simpangan baku. Pendekatan ini cocok untuk regresi dan analisis komponen utama yang sensitif terhadap skala. Perlu dicatat bahwa target ikut distandarisasi dalam proses notebook sehingga interpretasi akhir dalam dolar memerlukan pengembalian ke skala semula.

== Lakukan encoding atribut kategoris dengan one hot encoding

Pemeriksaan kardinalitas pada 38 atribut kategoris menghasilkan dua kelompok. Kelompok kardinalitas tinggi di atas 10 hanya berisi tiga atribut yaitu Neighborhood 25 nilai, Exterior2nd 16 nilai, dan Exterior1st 15 nilai. Kelompok kardinalitas rendah berisi 35 atribut dengan 10 nilai atau kurang. Contohnya Condition1 9 nilai, SaleType 9 nilai, RoofMatl 8 nilai, Condition2 8 nilai, HouseStyle 8 nilai, BsmtFinType2 7 nilai, Functional 7 nilai, GarageType 7 nilai, Foundation 6 nilai, Electrical 6 nilai termasuk kategori Tidak Ada, FireplaceQu 6 nilai termasuk kategori Tidak Ada, sampai Street 2 nilai, Utilities 2 nilai, dan CentralAir 2 nilai.

Strategi encoding dibagi dua agar memenuhi prinsip one hot encoding sekaligus menjaga dimensi tetap terkendali.

Untuk 35 atribut kardinalitas rendah digunakan one hot encoding dengan pembuangan satu level acuan. Hasilnya berupa kolom biner seperti Street Pave, CentralAir Ya, Utilities Tanpa Sewer, PavedDrive P, PavedDrive Y, LandSlope Moderat, LandSlope Berat, GarageFinish Tidak Ada, GarageFinish RFn, dan GarageFinish Unf. Pembuangan satu level bertujuan menghindari kolinearitas sempurna antar kolom biner. Pendekatan ini tepat karena ledakan dimensi masih terkendali untuk atribut dengan sedikit nilai.

Untuk tiga atribut kardinalitas tinggi digunakan target encoding. Setiap kategori diganti dengan representasi berbasis rata rata target yang dihaluskan. Alasannya adalah efisiensi dimensi dan stabilitas. Jika Neighborhood dengan 25 wilayah diubah menjadi 24 kolom biner, maka banyak kolom akan jarang terisi dan rawan overfit. Hal yang sama berlaku untuk Exterior1st dan Exterior2nd. Dengan target encoding, tiap atribut hanya menjadi satu kolom numerik yang tetap menyimpan perbedaan harga antar kategori.

Hasil akhir tahap ini adalah 1460 baris kali 195 kolom. Perluasan dari 75 kolom menjadi 195 kolom berasal dari kolom biner one hot ditambah tiga kolom hasil target encoding. Dataset hasil preprocessing ini disimpan sebagai berkas CSV final untuk kebutuhan pemodelan.

= Reduksi Dimensi

== Gunakan analisis korelasi untuk mengidentifikasi atribut yang sangat berkorelasi

Analisis korelasi menemukan beberapa kelompok atribut yang saling berkaitan erat secara konsep dan angka. Kelompok garasi berkaitan antara kapasitas mobil dan luas garasi yang masing masing berkorelasi sekitar 0.64 dan 0.62 dengan harga. Kelompok luas hunian berkaitan antara First Floor SF, Second Floor SF, GrLivArea, dan TotalBsmtSF karena total luas merupakan penjumlahan komponen lantai dan basement. Kelompok ruangan berkaitan antara jumlah kamar, jumlah kamar mandi, dan total ruangan. Kelompok tahun berkaitan antara YearBuilt, YearRemodAdd, dan GarageYrBlt karena umur bangunan saling mengikuti. Kelompok eksterior berkaitan antara Exterior1st dan Exterior2nd karena material kedua sering mengikuti material pertama.

Pendekatan yang diambil bukan membuang satu dari tiap pasangan secara manual. Alasannya adalah tiap atribut masih menyimpan nuansa unik. First Floor SF dan Second Floor SF memang berkaitan dengan total luas, tetapi komposisi lantai satu versus lantai dua memiliki makna arsitektural berbeda. YearBuilt dan YearRemodAdd memang berkaitan, tetapi selisihnya menyimpan informasi renovasi. Karena itu reduksi dilakukan secara multivariat melalui pemeriksaan inflasi varians dan analisis komponen utama yang lebih sistematis.

== Gunakan analisis inflasi varians dan PCA untuk mengurangi dimensi

Pemeriksaan multikolinearitas menemukan 8 atribut dengan inflasi varians di atas 10 yaitu GrLivArea sekitar 1059.50, Second Floor SF sekitar 730.82, First Floor SF sekitar 573.70, TotalBsmtSF sekitar 36.87, BsmtFinSF1 sekitar 35.99, BsmtUnfSF sekitar 35.27, Exterior2nd sekitar 11.08, dan Exterior1st sekitar 10.42. Atribut berikutnya seperti LowQualFinSF sekitar 8.97 dan YearBuilt sekitar 5.65 masih di bawah ambang tinggi. Nilai di atas 500 menandakan kolinearitas nyaris sempurna sehingga koefisien regresi akan tidak stabil jika dibiarkan.

#figure(
  image("../output/figures/cell39_out1_fig5.png", width: 100%),
  caption: [Inflasi varians tiap fitur numerik dalam skala log. Warna merah menandakan high VIF di atas 10.],
) <fig-vif-log>

#figure(
  image("../output/figures/cell39_out2_fig6.png", width: 100%),
  caption: [15 inflasi varians tertinggi dalam skala linear. Tiga fitur luas mendominasi dengan nilai ratusan sampai ribuan.],
) <fig-vif-top>

Analisis komponen utama diterapkan khusus pada 8 atribut high VIF tersebut. Sebelum analisis, kedelapan atribut distandarisasi karena analisis komponen utama sensitif terhadap skala. Komponen baru yang dihasilkan bersifat ortogonal atau tidak saling berkorelasi sehingga cocok untuk menggantikan kelompok yang kolinear.

Hasil variance yang dijelaskan adalah PC1 sekitar 36.82 persen, PC2 sekitar 22.79 persen dengan kumulatif 59.61 persen, PC3 sekitar 18.97 persen dengan kumulatif 78.58 persen, PC4 sekitar 17.04 persen dengan kumulatif 95.62 persen, PC5 sekitar 3.17 persen dengan kumulatif 98.80 persen, dan sisanya di bawah satu persen. Kebutuhan untuk ambang 80 persen, 90 persen, dan 95 persen semuanya terpenuhi pada 4 komponen dengan retensi aktual 95.62 persen. Karena itu dipilih 4 komponen. Artinya 8 atribut dimampatkan menjadi 4 dengan penghematan 50 persen dimensi untuk blok kolinear tanpa kehilangan banyak informasi.

#figure(
  image("../output/figures/cell40_out1_fig7.png", width: 100%),
  caption: [Scree plot dan cumulative variance. Empat komponen pertama sudah menjelaskan sekitar 95.62 persen varians.],
) <fig-scree>

Interpretasi bobot menunjukkan PC1 didominasi TotalBsmtSF, First Floor SF, GrLivArea, dan material eksterior sehingga dapat dibaca sebagai faktor ukuran total. PC2 memisahkan finishing basement versus lantai atas dan eksterior. PC3 didominasi Second Floor SF dan GrLivArea sehingga dapat dibaca sebagai faktor lantai dua. PC4 mempertentangkan basement belum jadi versus basement sudah jadi. Biplot PC1 versus PC2 yang diwarnai harga menunjukkan rumah mahal cenderung mengarah ke vektor ukuran total. Hal ini mengonfirmasi bahwa PC1 menangkap proksi kemewahan ukuran.

#figure(
  image("../output/figures/cell41_out1_fig8.png", width: 100%),
  caption: [Heatmap bobot dan biplot PC1 versus PC2],
) <fig-biplot>

Tahap penggabungan membuang 8 kolom high VIF dan menempelkan 4 skor komponen sehingga dimensi berubah dari 195 kolom menjadi 191 kolom dengan 1460 baris tetap. Kolom PC baru adalah PC1 sampai PC4. Atribut low VIF, hasil encoding, dan SalePrice tetap dipertahankan.

#figure(
  image("../output/figures/cell42_out3_fig9.png", width: 100%),
  caption: [Sebaran PC1 versus PC2 yang diwarnai harga serta distribusi PC1 yang mendekati simetris.],
) <fig-pca-result>

Validasi menunjukkan keberhasilan reduksi. Inflasi varians sesudah analisis untuk PC1 sampai PC4 semuanya sekitar 1.0. Korelasi antar komponen mendekati nol dengan nilai 1.0 pada diagonal dan nol pada luar diagonal. Artinya kolinearitas hilang, dimensi berkurang, dan sekitar 95.62 persen informasi blok kolinear tetap terjaga.

= Penutup

Ringkasan alur preprocessing adalah sebagai berikut. Data awal 1460 kali 80 dibersihkan dari lima kolom dengan missing di atas 50 persen menjadi 1460 kali 75. Nilai hilang sisa diisi dengan kategori Tidak Ada untuk atribut yang objeknya memang tidak ada dan nilai tengah untuk atribut numerik miring sehingga missing menjadi nol. Outlier diperiksa dengan boxplot dan diputuskan untuk disesuaikan, bukan dihapus, karena alasan rumah mewah dan bukti korelasi. Sepuluh atribut miring dibatasi pada kuantil 1 persen dan 99 persen lalu ditransformasi logaritmik. Seluruh atribut numerik distandarisasi ke skor z. Atribut kategori kardinalitas rendah diubah dengan one hot encoding dan tiga atribut kardinalitas tinggi diubah dengan target encoding sehingga dimensi menjadi 1460 kali 195. Reduksi korelasi dilakukan melalui pemeriksaan inflasi varians yang menemukan 8 atribut high VIF, lalu 8 atribut tersebut dimampatkan menjadi 4 komponen utama dengan retensi 95.62 persen sehingga dimensi akhir gabungan menjadi 1460 kali 191 dengan inflasi varians 1.0 dan korelasi antar komponen nol. Dataset 195 kolom menjadi keluaran preprocessing untuk pemodelan, sedangkan versi 191 kolom menjadi artefak reduksi dimensi yang siap dipakai untuk regresi yang stabil.
