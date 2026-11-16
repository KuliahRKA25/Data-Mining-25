#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.2cm, left: 2.5cm, right: 2.5cm),
  numbering: "1",
  number-align: right + bottom,
)

#set text(font: "New Computer Modern", size: 11pt, lang: "id")
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1.")
#set list(indent: 1.2em, body-indent: 0.5em, spacing: 0.4em)
#show heading: set block(above: 1.4em, below: 1em)
#show figure.caption: set text(size: 9.5pt)
#show figure: set block(breakable: false)
// Keterangan tabel diletakkan di atas tabel
#show figure.where(kind: table): set figure.caption(position: top)

// ---------- Komponen ----------
// Tabel bergaya booktabs: garis tebal atas/bawah, garis tipis di bawah header
#let btable(columns: auto, align: left + horizon, size: 9pt, header: (), ..rows) = {
  set text(size: size)
  table(
    columns: columns,
    align: align,
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    table.hline(y: 0, stroke: 1pt),
    table.header(..header.map(h => strong(h))),
    table.hline(y: 1, stroke: 0.6pt),
    ..rows,
    table.hline(stroke: 1pt),
  )
}

// Diagram batang horizontal sederhana (persentase)
#let hbar(title, items, color: rgb("#3b6ea8")) = {
  align(center, text(size: 9pt, weight: "bold", title))
  v(2pt)
  set text(size: 8pt)
  grid(
    columns: (2.2cm, 1fr, 1.2cm),
    row-gutter: 3pt,
    column-gutter: 4pt,
    align: (right + horizon, left + horizon, left + horizon),
    ..items.map(((lbl, v)) => (
      lbl,
      box(width: 100%, height: 9pt, align(left, rect(width: v * 1%, height: 9pt, fill: color, stroke: none))),
      [#v%],
    )).flatten(),
  )
}

#let img(path, width: 100%) = image(path, width: width)

// ---------- Identitas makalah ----------
#align(center)[
  #set par(first-line-indent: 0pt, justify: false)

  #text(size: 16pt, weight: "bold")[
    Review Jurnal: A novel hybrid TabTransformer–LightGBM framework for explainable intrusion detection in smart farming IoT networks
  ]

  #v(0.8em)

  #text(size: 11pt)[
    Benedictus Ryu Gunawan#super[1],
    Muhammad Fasya Atthaya Rosyada#super[2],
    Pranaja Adyatma Budiman#super[3]
  ]

  #v(0.4em)

  #text(size: 10pt)[
    #super[1,2,3] Rekayasa Kecerdasan Artifisial, Institut Teknologi Sepuluh Nopember
  ]
  #linebreak()

  #text(size: 10pt)[
    #super[#sym.ast]Corresponding author's email: #super[1]$"5054251001@student.its.ac.id"$, #super[2]$"5054251006@student.its.ac.id"$, #super[3]$"5054251009@student.its.ac.id"$
  ]
]

#v(0.6em)

#block(
  width: 100%,
  stroke: 0.6pt + luma(150),
  radius: 4pt,
  inset: 8pt,
  text(size: 9.5pt)[
    *Paper yang direview:* M L, A. E. M., S, P., Thirumalaisamy, M., Kaliyaperumal, P., Balusamy, B., & Benedetto, F. (2026). A novel hybrid TabTransformer–LightGBM framework for explainable intrusion detection in smart farming IoT networks. _Computers and Electrical Engineering, 138_, 111344. ScienceDirect (Elsevier). https://doi.org/10.1016/j.compeleceng.2026.111344
  ],
)

#v(0.6em)

// ============================================================
= Data yang Digunakan

== Gambaran Umum Dataset

Penelitian ini menggunakan dua dataset utama yang sama-sama dirilis oleh Canadian Institute for Cybersecurity (CIC), University of New Brunswick, yaitu *CIC IoT 2023* dan *CIC IoT-DIAD 2024*. Keduanya dibangkitkan dari _testbed_ IoT berskala besar yang terdiri atas 105 perangkat heterogen dan memuat 33 subtipe serangan yang dikelompokkan ke dalam tujuh kategori utama: DDoS, DoS, Reconnaissance, Web-Based, Brute Force, Spoofing, dan Mirai. Data tersedia dalam bentuk berkas PCAP mentah dan fitur CSV hasil ekstraksi tingkat _flow_. Pada CIC IoT-DIAD 2024 yang dirancang untuk dua tujuan (_Device Identification_ dan _Anomaly Detection_), penulis hanya menggunakan subset _Anomaly Detection_. Sebagai validasi eksternal, penulis juga menguji kerangka yang sama pada dataset *UNSW-NB15* yang memiliki karakteristik lalu lintas, distribusi protokol, dan metode pembangkitan fitur yang berbeda (M L dkk., 2026). Ringkasan ketiga dataset disajikan pada @tab-dataset.

#figure(
  btable(
    columns: (2.6cm, 1fr, 1fr, 1fr),
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    header: ([Karakteristik], [CIC IoT 2023], [CIC IoT-DIAD 2024], [UNSW-NB15]),
    [Peran], [Data latih & uji utama], [Data latih & uji utama], [Validasi eksternal],
    [Jumlah instans], [48.886.975#super[a]], [12.567.935], [–],
    [Jumlah fitur], [39 (flow, protokol, header)], [80–83 (flow, arah, temporal)], [–],
    [Kategori serangan], [7 kategori, 33 subtipe], [7 kategori (subset)], [Beragam],
    [Benign], [1.098.191], [398.330], [–],
    [Attack], [48.788.784#super[a]], [12.169.605], [–],
    [Rasio benign : attack], [1 : 44,42#super[a]], [1 : 30,55], [–],
    [Komposisi dominan], [DDoS], [DoS], [–],
  ),
  caption: [Ringkasan dataset yang digunakan. #super[a]Angka sesuai yang dilaporkan paper; penjumlahan ulang Tabel 1 paper menghasilkan 44.788.784 serangan (rasio 1 : 40,78), lihat Bab 4.],
  supplement: [Tabel],
  kind: table,
) <tab-dataset>

== Atribut dan Tipe Data

Kedua dataset menyimpan data dalam bentuk *tabular*, dengan satu baris merepresentasikan satu _flow_ jaringan. Fiturnya bersifat heterogen: terdapat variabel kategorikal (misalnya protokol, _service_, IP sumber, port tujuan), variabel ordinal/diskret (jumlah _flag_ TCP, nilai TTL), variabel biner (indikator protokol seperti HTTP, DNS, TCP, UDP), serta variabel numerik kontinu (panjang paket, durasi _flow_, statistik _inter-arrival time_/IAT). CIC IoT 2023 menyediakan set fitur yang lebih ringkas tanpa pemisahan arah, sedangkan CIC IoT-DIAD 2024 menambahkan statistik per arah (_forward/backward_), indikator protokol lapisan aplikasi yang lebih rinci, metrik performa _flow_, dan atribut VLAN. Pengelompokan atribut beserta tipe datanya dirangkum pada @tab-atribut.

#figure(
  btable(
    columns: (2.4cm, 3.4cm, 3.6cm, 2.6cm, 1fr),
    size: 8pt,
    header: ([Kategori], [CIC IoT 2023], [CIC IoT-DIAD 2024], [Tipe Data], [Keterangan]),
    [Protocol & Header], [Header_Length, Protocol Type, Time_To_Live], [Protocol, Flow Duration, Flow IAT Mean, Fwd Header Length], [Kategorikal (protokol); numerik (panjang header, TTL)], [Overlap: protocol type, header length, TTL],
    [Flag Counters], [fin_flag_number, syn_flag_number, rst_flag_number, dll.], [Fwd FIN Flag Count, Bwd SYN Flag Count, dll.], [Ordinal / diskret (_count_)], [2024 memisahkan arah _forward/backward_],
    [Service Indicators], [HTTP, HTTPS, DNS, Telnet, SMTP, SSH, IRC], [Flag protokol aplikasi rinci (FTP, POP3, IMAP, dll.)], [Biner (0/1)], [Overlap: HTTP, HTTPS, DNS, SMTP, SSH],
    [Transport Protocols], [TCP, UDP], [TCP, UDP, SCTP], [Biner (0/1)], [2024 menambah SCTP],
    [Network Protocols], [DHCP, ARP, ICMP, IGMP, IPv, LLC], [Sama + VLAN tagging], [Biner; kategorikal (VLAN ID)], [2024 menambah VLAN ID],
    [Statistical Metrics], [Tot sum, Min, Max, AVG, Std, Tot size, IAT, Number, Variance], [Fwd Packet Length Mean, Bwd IAT Std, dll.], [Numerik kontinu], [Statistik paket/IAT per _flow_],
    [Extra Flow Attributes], [–], [Flow Bytes/s, Flow Packets/s, Active Mean, Idle Std, Subflow Fwd Bytes], [Numerik kontinu], [Hanya ada di 2024],
    [Label], [Subtipe serangan / Benign], [Subtipe serangan / Benign], [Kategorikal → biner], [Dipetakan menjadi Benign (0) vs Attack (1)],
  ),
  caption: [Atribut dan tipe data pada CIC IoT 2023 dan CIC IoT-DIAD 2024 (diadaptasi dari Tabel 3 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-atribut>

== Contoh Sampel Data

Paper tidak mencantumkan baris data mentah, tetapi menyajikan distribusi lengkap setiap subtipe. @tab-sampel menampilkan contoh sampel label dari kedua dataset, yaitu subtipe asli, kategori serangannya, jumlah _flow_, dan label biner yang digunakan sebagai target deteksi. Terlihat bahwa satu label biner "Attack" menaungi subtipe dengan jumlah yang sangat timpang, mulai dari jutaan (ICMP Flood) hingga hanya lima sampel (TCP_Flood pada DIAD 2024).

#figure(
  btable(
    columns: (2.4cm, 3.2cm, 2.4cm, 2.2cm, 1fr),
    align: (left + horizon, left + horizon, left + horizon, right + horizon, center + horizon),
    size: 8.5pt,
    header: ([Dataset], [Subtipe], [Kategori], [Jumlah], [Label Biner]),
    [CIC IoT 2023], [Benign traffic], [Benign], [1.098.191], [Benign (0)],
    [CIC IoT 2023], [ICMP Flood], [DDoS], [7.200.504], [Attack (1)],
    [CIC IoT 2023], [SYN Flood], [DoS], [2.028.834], [Attack (1)],
    [CIC IoT 2023], [Port Scan], [Recon], [82.284], [Attack (1)],
    [CIC IoT 2023], [SQL Injection], [Web-Based], [5.245], [Attack (1)],
    [CIC IoT 2023], [GREIP Flood], [Mirai], [751.682], [Attack (1)],
    [CIC IoT 2023], [Dictionary Brute Force], [Brute Force], [13.064], [Attack (1)],
    [CIC IoT-DIAD 2024], [Benign Traffic], [Benign], [398.330], [Benign (0)],
    [CIC IoT-DIAD 2024], [UDP Flood], [DoS], [5.210.536], [Attack (1)],
    [CIC IoT-DIAD 2024], [ACK_Frag], [DDoS], [2.450.086], [Attack (1)],
    [CIC IoT-DIAD 2024], [ARP Spoofing], [Spoofing], [82.382], [Attack (1)],
    [CIC IoT-DIAD 2024], [TCP_Flood], [DoS], [5], [Attack (1)],
  ),
  caption: [Contoh sampel label dari CIC IoT 2023 dan CIC IoT-DIAD 2024 beserta pemetaan ke label biner (diambil dari Tabel 1 dan Tabel 2 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-sampel>

// ============================================================
= Latar Belakang dan Deteksi Anomali

== Problem yang Dibahas

_Smart farming_ atau pertanian presisi memanfaatkan sensor, aktuator, _drone_, dan jaringan komunikasi untuk memantau kondisi tanah, penggunaan air, kesehatan tanaman, dan cuaca secara _real-time_. Data dari perangkat IoT tersebut dikirim ke _cloud_ untuk dianalisis sehingga petani dapat mengoptimalkan irigasi, pemupukan, dan pengendalian hama. Namun, ketergantungan pada perangkat IoT yang saling terhubung dan infrastruktur _cloud_ membuka permukaan serangan yang luas. Serangan DDoS dapat melumpuhkan _gateway_, _spoofing_ dapat menyuntikkan data sensor palsu sehingga keputusan irigasi atau penyemprotan pestisida menjadi salah, sedangkan _malware_ dan akses tidak sah mengancam integritas data dan kelangsungan operasi (@fig-ancaman). Dampaknya tidak hanya kerugian finansial, tetapi juga gangguan keamanan pangan serta kerusakan tanaman dan ternak.

#figure(
  img("gambar/fig3_ancaman.png", width: 70%),
  caption: [Visualisasi keamanan sistem _smart farming_ yang menunjukkan vektor ancaman seperti _malware_, _spoofing_, dan telemetri anomali (Fig. 3 pada paper).],
  supplement: [Gambar],
) <fig-ancaman>

Penulis mengidentifikasi lima tantangan utama _Intrusion Detection System_ (IDS) yang ada pada lingkungan _smart farming_: (1) data IoT bersifat heterogen dengan campuran fitur kategorikal dan numerik sehingga sulit dimodelkan tanpa _feature engineering_ manual; (2) pergeseran domain (_domain shift_) akibat variasi perangkat dan kondisi penerapan menurunkan generalisasi antar-lahan; (3) data serangan berlabel, terutama serangan langka atau _zero-day_, sangat terbatas; (4) perangkat _edge_ memiliki sumber daya komputasi dan energi yang terbatas; serta (5) banyak model IDS bersifat _black-box_ sehingga operator tidak percaya pada peringatan yang dihasilkan. Selain itu, lalu lintas _smart farming_ bersifat non-stasioner karena dipengaruhi siklus irigasi, cuaca, dan interval pemantauan tanaman, sehingga pola normal pun dapat terlihat tidak teratur.

== Deteksi Anomali yang Dilakukan

Deteksi anomali dalam paper ini diformulasikan sebagai *deteksi intrusi jaringan berbasis klasifikasi biner terawasi (_supervised_)*, yaitu membedakan _flow_ jaringan *Benign* (normal) dari *Attack* (anomali). Ketujuh kategori dan 33 subtipe serangan digabung menjadi satu kelas anomali. Penulis memilih formulasi biner secara sengaja karena ketimpangan kelas yang parah membuat klasifikasi multikelas bias terhadap kelas mayoritas dan kurang andal untuk serangan minoritas. Dalam konteks operasional, respons cepat seperti mengisolasi sensor yang terkompromi atau memblokir lalu lintas berbahaya cukup dipicu oleh deteksi anomali yang andal tanpa perlu mengetahui jenis serangannya, sehingga model ini diposisikan sebagai lapisan deteksi tahap pertama dalam arsitektur keamanan hierarkis.

Selain anomali tingkat _flow_, model diharapkan secara implisit menangkap *anomali perilaku perangkat*, misalnya perintah aktuator yang tidak wajar, frekuensi penginderaan yang abnormal, dan penyalahgunaan protokol, serta membedakannya dari fluktuasi lingkungan yang normal (misalnya lonjakan lalu lintas saat jadwal irigasi).

== Visualisasi Anomali

Paper memvisualisasikan anomali melalui beberapa cara. Pertama, distribusi kelas pada @fig-distribusi memperlihatkan bahwa anomali (serangan) justru merupakan kelas mayoritas, sedangkan lalu lintas normal hanya sekitar 2–3% data. Kedua, _confusion matrix_ (@fig-cm) memperlihatkan seberapa banyak anomali yang terdeteksi dan lalu lintas normal yang salah dianggap anomali. Ketiga, analisis SHAP lokal menjelaskan pola anomali per kejadian. Pada serangan *DoS SYN Flood*, fitur SYN Flag Count, Flow Duration, dan Flow Bytes/s memberi kontribusi positif yang kuat ke arah kelas "Attack", sementara ACK Flag Count sedikit menyeimbangkan tetapi tidak cukup kuat untuk membalikkan keputusan. Pada skenario *Data Exfiltration*, fitur Packet Length Mean, Subflow Fwd Bytes, dan Flow IAT Std mendorong prediksi ke "Attack", sedangkan Protocol Type yang stabil berkontribusi negatif sehingga mengurangi risiko _false positive_. Analisis _false positive_ juga menunjukkan bahwa lalu lintas normal yang salah dideteksi umumnya memiliki pola transmisi _bursty_, distribusi panjang paket tidak teratur, variabilitas _flow_ tinggi, dan kombinasi _flag_ ACK/SYN yang tidak lazim, sehingga menyerupai pola serangan.

// ============================================================
= Tujuan dan Manfaat Penelitian

Tujuan utama paper ini adalah mengembangkan kerangka deteksi intrusi yang akurat, skalabel, dan dapat dijelaskan untuk menghadapi tantangan keamanan IoT _smart farming_ yang dinamis dan heterogen. Secara rinci, penulis menetapkan empat tujuan: (1) membangun model deteksi intrusi yang mampu menangkap interaksi kompleks antar-fitur IoT yang heterogen; (2) merancang kerangka IDS berbasis _cloud_ yang skalabel untuk mengatasi keterbatasan sumber daya perangkat _edge_ sekaligus memungkinkan deteksi mendekati _real-time_; (3) mengintegrasikan teknik _explainability_ yang memberikan wawasan transparan dan dapat ditindaklanjuti atas setiap peringatan intrusi; serta (4) mengevaluasi dan memvalidasi kerangka tersebut pada CIC IoT 2023 dan CIC IoT-DIAD 2024 dengan membandingkannya terhadap pendekatan IDS lain dari sisi akurasi, ketahanan, dan interpretabilitas.

Dari sisi manfaat, kerangka hybrid TabTransformer–LightGBM–SHAP memberikan beberapa kontribusi praktis. TabTransformer menghilangkan kebutuhan _feature engineering_ manual pada data tabular heterogen, sedangkan LightGBM menjamin inferensi cepat (sekitar 3,5 ms per instans atau sekitar 285 permintaan per detik), sehingga sistem layak dipakai untuk pemantauan mendekati _real-time_. SHAP mengubah IDS dari sekadar prediktor menjadi alat bantu keputusan yang dapat diaudit, karena operator dapat melihat sinyal apa yang memicu peringatan dan segera melakukan triase. Penerapan pada _cloud_ dengan GPU komoditas (NVIDIA T4) diperkirakan hanya membutuhkan biaya sekitar USD 0,52–0,65 per jam (USD 375–470 per bulan), sehingga ekonomis untuk lahan pertanian skala menengah. Validasi lintas-dataset dan pada UNSW-NB15 juga memberikan bukti bahwa model tidak hanya menghafal pola satu dataset, sehingga lebih relevan untuk lahan pertanian dengan karakteristik jaringan yang berbeda-beda.

// ============================================================
= Exploratory Data Analysis (EDA)

Paper tidak memiliki bab EDA tersendiri. Namun, beberapa analisis eksploratif dilakukan secara tersebar dan hasilnya secara langsung membentuk keputusan desain model. EDA yang teridentifikasi dirangkum pada @tab-eda.

#figure(
  btable(
    columns: (3.2cm, 1fr, 1fr),
    size: 8.5pt,
    header: ([Analisis EDA], [Temuan], [Pengaruh terhadap Desain]),
    [Distribusi kategori & subtipe serangan (Tabel 1–2 paper)], [CIC IoT 2023 didominasi DDoS; DIAD 2024 didominasi DoS; Recon, Web, Brute Force, Spoofing sangat jarang], [Formulasi biner dipilih agar tidak bias pada kelas langka; kedua dataset digabung agar komposisi serangan lebih beragam],
    [Rasio ketimpangan kelas], [Benign : Attack = 1 : 44,42 (2023) dan 1 : 30,55 (2024)], [_Class-weighted learning_ (`scale_pos_weight`), _balanced batch sampling_, metrik selain akurasi (precision, recall, specificity, F1)],
    [Perbandingan komposisi fitur (Tabel 3 paper)], [39 vs 80 fitur; sebagian _overlap_, sebagian unik (arah, VLAN, SCTP, metrik _flow_)], [Harmonisasi skema; pemilihan TabTransformer yang dapat menyerap fitur heterogen],
    [Pemeriksaan kualitas data], [Tidak ada _missing value_ atau rekaman korup], [Tidak diperlukan imputasi],
    [Inspeksi distribusi fitur numerik], [Byte count, ukuran paket, dan durasi _flow_ sangat _skewed/heavy-tailed_ dengan _outlier_ ekstrem], [Transformasi log sebelum _z-score_],
    [Analisis redundansi fitur (SHAP + _gain_ LightGBM)], [Hanya sebagian fitur yang berkontribusi kuat; banyak fitur berkorelasi], [Tidak dilakukan seleksi fitur eksplisit karena reduksi ke 20 fitur teratas justru menurunkan performa],
  ),
  caption: [Rangkuman proses EDA yang teridentifikasi dalam paper dan pengaruhnya terhadap desain metode.],
  supplement: [Tabel],
  kind: table,
) <tab-eda>

Analisis distribusi kategori merupakan EDA yang paling berpengaruh. Proporsi tiap kategori terhadap total lalu lintas serangan dihitung ulang dari Tabel 1 dan Tabel 2 paper dan divisualisasikan pada @fig-distribusi. Pada CIC IoT 2023, DDoS mencakup sekitar 74% lalu lintas serangan, diikuti DoS (18%) dan Mirai (6%). Sebaliknya, CIC IoT-DIAD 2024 didominasi DoS (65%) dengan porsi DDoS sekitar 29%, serta porsi Recon yang relatif lebih besar (3,6%). Perbedaan komposisi ini menjadi dasar argumen penulis bahwa penggabungan kedua dataset dan evaluasi lintas-dataset dapat mensimulasikan _domain shift_ antar-lahan pertanian.

#figure(
  block(
    width: 100%,
    stroke: 0.6pt + luma(150),
    radius: 6pt,
    inset: 8pt,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 14pt,
      hbar("CIC IoT 2023 (% dari serangan)", (
        ("DDoS", 74.09), ("DoS", 18.06), ("Mirai", 5.88), ("Spoofing", 1.09),
        ("Recon", 0.79), ("Web-Based", 0.06), ("Brute Force", 0.03),
      )),
      hbar("CIC IoT-DIAD 2024 (% dari serangan)", (
        ("DoS", 64.93), ("DDoS", 28.59), ("Recon", 3.63), ("Mirai", 1.43),
        ("Spoofing", 1.29), ("Web-Based", 0.09), ("Brute Force", 0.03),
      ), color: rgb("#c0603a")),
    ),
  ),
  caption: [Distribusi kategori serangan pada kedua dataset (dihitung ulang dari Tabel 1 dan Tabel 2 paper). Lalu lintas benign hanya 2,4% (CIC IoT 2023) dan 3,2% (CIC IoT-DIAD 2024) dari seluruh _flow_.],
  supplement: [Gambar],
) <fig-distribusi>

EDA ini membantu analisis problem dalam tiga hal. Pertama, EDA mengungkap bahwa pada data ini anomali adalah kelas mayoritas, kebalikan dari asumsi umum deteksi anomali, sehingga akurasi saja tidak informatif dan model perlu dievaluasi dengan _specificity_ untuk mengukur kemampuan mengenali lalu lintas normal. Kedua, temuan distribusi fitur yang _skewed_ langsung mengarahkan pemilihan transformasi log. Ketiga, analisis redundansi menjustifikasi keputusan untuk tidak melakukan seleksi fitur.

Hasil penghitungan ulang juga menemukan inkonsistensi angka. Penjumlahan Tabel 1 paper menghasilkan 44.788.784 _flow_ serangan dan total 45.886.975 _flow_, bukan 48.788.784 dan 48.886.975 seperti yang dilaporkan, sehingga rasio sebenarnya sekitar 1 : 40,78, bukan 1 : 44,42. Klaim bahwa DDoS mencakup "lebih dari 95%" lalu lintas serangan CIC IoT 2023 juga tidak sesuai dengan Tabel 1 (sekitar 74%; DDoS dan DoS bersama sekitar 92%). Perbedaan ini tidak mengubah kesimpulan umum, tetapi memengaruhi nilai `scale_pos_weight` yang digunakan.

// ============================================================
= Teknik Preprocessing

== Tahapan Preprocessing

Meskipun kedua dataset sudah dibersihkan oleh CIC, preprocessing tetap diperlukan agar data kompatibel dengan arsitektur hybrid dan konsisten antar-dataset. Tahapan preprocessing dan persiapan data dirangkum pada @tab-praproses, sedangkan posisinya dalam alur sistem ditampilkan pada @fig-framework.

#figure(
  btable(
    columns: (3cm, 1fr, 3.6cm),
    size: 8.5pt,
    header: ([Tahap], [Konfigurasi], [Tujuan]),
    [Dataset Harmonization], [Hanya atribut yang ada di kedua dataset dipertahankan; urutan kolom distandarkan; nama fitur dinormalisasi ke huruf kecil (`Flow_Duration` → `flow_duration`); tipe numerik di-_cast_ ke _float_, kategorikal ke ID integer/string], [Skema terpadu untuk pelatihan dan evaluasi gabungan],
    [Log-transformation], [Diterapkan pada fitur _heavy-tailed_ (byte count, ukuran paket, durasi _flow_) sebelum _scaling_], [Mengompresi _outlier_ ekstrem; menstabilkan _split_ pohon LightGBM],
    [_z-score_ normalization], [Mean dan simpangan baku dihitung *hanya dari data latih*], [Rata-rata 0, simpangan baku 1; mencegah _data leakage_],
    [Encoding kategorikal], [Protokol, _service_, dan _flag_ dipetakan ke ID integer dengan pemetaan kategori-ke-ID yang seragam di kedua dataset, lalu diteruskan ke _embedding layer_ TabTransformer], [Representasi padat; mencegah error kategori tak dikenal saat inferensi],
    [Penanganan imbalance class], [Semua sampel dipertahankan (tanpa _down-sampling_); `scale_pos_weight` = 44,42 (2023) dan 30,55 (2024) pada LightGBM; _class-weighted loss_ dan _balanced batch sampling_ pada TabTransformer], [Mencegah bias ke kelas mayoritas],
    [feature selection], [Tidak dilakukan; relevansi fitur dipelajari implisit oleh _self-attention_ dan _split_ pohon], [Mempertahankan informasi perilaku],
    [data _split_], [Data gabungan diacak dan dibagi 70% latih, 10% validasi, 20% uji dengan distribusi kelas dipertahankan; _seed_ = 42], [Evaluasi realistis dan reprodusibel],
  ),
  caption: [Teknik preprocessing dan persiapan data yang digunakan pada kerangka TabTransformer–LightGBM.],
  supplement: [Tabel],
  kind: table,
) <tab-praproses>

#figure(
  img("gambar/fig4_framework.png", width: 52%),
  caption: [Alur kerangka sistem: data CIC IoT → _Data Pre-Processing_ (hijau) → _Data Preparation_ (merah muda) → TabTransformer → LightGBM → klasifikasi biner → SHAP → _cloud deployment_ dan SOC (Fig. 4 pada paper).],
  supplement: [Gambar],
) <fig-framework>

== Analisis Pengaruh Preprocessing terhadap Hasil Eksperimen

Paper tidak menyajikan ablasi khusus untuk setiap langkah preprocessing, sehingga pengaruhnya hanya dapat dianalisis secara tidak langsung dari hasil eksperimen yang tersedia.

*Harmonization dan encoding.* Langkah ini memungkinkan kedua dataset dilatih bersama dan diuji silang. Tanpa skema yang seragam, evaluasi lintas-dataset pada @tab-cross tidak dapat dilakukan. Hasil lintas-dataset sebesar 92,86–93,52% (dibandingkan 98,83–99,18% pada dataset yang sama) menunjukkan bahwa harmonisasi berhasil membuat model tetap berfungsi pada distribusi yang berbeda. Namun, penurunan sekitar 5–6 poin juga menunjukkan bahwa harmonisasi skema saja belum cukup menghilangkan _domain shift_. Perlu dicatat juga bahwa mempertahankan hanya fitur yang sama di kedua dataset bertentangan dengan analisis SHAP yang menempatkan fitur unik DIAD 2024 (Flow Duration, Flow Bytes/s, Subflow Fwd Bytes) dan fitur unik CIC IoT 2023 (TTL, DNS Service Indicator) di peringkat teratas. Paper tidak menjelaskan bagaimana kedua hal ini dapat terjadi bersamaan.

*Log-transformation dan _z-score_.* Fitur yang paling berpengaruh menurut SHAP adalah fitur volumetrik dan temporal yang justru paling _skewed_, yaitu Flow Duration (0,142), Packet Length Mean (0,126), dan Flow Bytes/s (0,105). Transformasi log membuat nilai ekstrem pada fitur-fitur ini tidak mendominasi _split_ pohon, sehingga model dapat memanfaatkannya secara stabil. Perhitungan statistik normalisasi hanya dari data latih juga membuat skor uji tidak terlalu optimistis akibat kebocoran data. Kurva _loss_ latih dan validasi yang konvergen tanpa divergensi (@fig-loss) menjadi indikasi pendukung bahwa input yang ternormalisasi membantu stabilitas pelatihan TabTransformer.

*Penangan imbalance class.* Dengan porsi benign hanya 2–3%, model naif yang selalu memprediksi "Attack" sudah mencapai akurasi sekitar 97%. Hasil _specificity_ sebesar 98,29–98,30% menunjukkan bahwa _class weighting_ berhasil membuat model tetap mengenali sebagian besar lalu lintas normal. Meskipun demikian, terdapat kejanggalan konseptual: pada LightGBM, `scale_pos_weight` memperbesar bobot kelas *positif*, sedangkan paper mendefinisikan positif sebagai "Attack" (TP = serangan terdeteksi). Jika diterapkan secara harfiah, nilai 30,55–44,42 justru memperbesar bobot kelas mayoritas, bukan kelas benign seperti yang diklaim. Ketidakjelasan ini membuat pengaruh _class weighting_ sulit direproduksi.

*Tanpa feature selection.* Inilah satu-satunya keputusan preprocessing yang diuji secara empiris. Model yang hanya memakai 20 fitur teratas berdasarkan SHAP mengalami sedikit penurunan pada semua metrik dibandingkan model dengan seluruh fitur. Artinya, fitur berperingkat rendah tetap membawa informasi tambahan, dan mekanisme _attention_ serta _split_ LightGBM sudah cukup meredam dampak fitur yang redundan.

*_split_ dan reprodusibilitas.* Penggunaan _seed_ tetap (42) serta pembagian 70/10/20 yang mempertahankan distribusi kelas membuat evaluasi berjalan pada kondisi ketimpangan yang realistis. Hasil _5-fold cross-validation_ dengan simpangan baku ≤ 0,20 (@tab-cv) menunjukkan bahwa hasil tidak bergantung pada satu partisi tertentu. Namun, pembagian acak tingkat _flow_ berisiko menempatkan _flow_ yang sangat mirip dari sesi serangan yang sama di data latih dan uji. Walaupun Fig. 4 menyebut adanya pencegahan kebocoran temporal dan perangkat, teks metodologi hanya menyebutkan pengacakan biasa.

// ============================================================
= Metode Deteksi Anomali dan Analisis Pengaruhnya

== Arsitektur Hybrid TabTransformer–LightGBM–SHAP

Metode yang diusulkan adalah *pipeline modular tiga lapis* yang memisahkan pembelajaran representasi, pengambilan keputusan, dan penjelasan.

+ *TabTransformer (pembelajaran representasi).* Setiap fitur kategorikal $x_(c_i)$ dipetakan menjadi vektor _embedding_ $e_i = E_i (x_(c_i))$. Matriks _embedding_ $E$ diproses oleh tumpukan _Transformer encoder_ dengan _multi-head self-attention_, $"Attention"(Q,K,V) = "softmax"(Q K^top \/ sqrt(d_k)) V$, untuk menangkap ketergantungan antar-fitur. _Embedding_ kontekstual $E'$ kemudian di-_flatten_ dan digabungkan dengan fitur numerik yang telah diskalakan: $Z = [X_n ; "Flatten"(E')]$.
+ *LightGBM (klasifikasi).* Matriks $Z$ menjadi input _gradient boosting decision tree_ dengan pertumbuhan pohon _leaf-wise_, _split_ berbasis histogram, dan _Exclusive Feature Bundling_. Model diperbarui secara iteratif dengan $F_t (x) = F_(t-1)(x) + eta h_t (x)$ dan fungsi _loss_ _binary cross-entropy_, menghasilkan keputusan Benign/Attack beserta skor kepercayaan.
+ *SHAP (explainability).* Nilai Shapley $phi_(i j)$ dihitung pada LightGBM untuk penjelasan *global* (kepentingan fitur rata-rata) dan *lokal* (kontribusi fitur pada satu kejadian), lalu dilampirkan pada peringatan yang dikirim ke _Security Operations Center_ (SOC).

Konfigurasi _hyperparameter_ utama ditampilkan pada @tab-hparam. Eksperimen dijalankan di Google Colab Pro (NVIDIA Tesla T4, 2 vCPU, RAM 16 GB, Python 3.10, TensorFlow, LightGBM, SHAP). Evaluasi menggunakan Accuracy, Precision, Recall, Specificity, F1-score, dan AUC-ROC.

#figure(
  btable(
    columns: (1fr, 1.4cm, 1fr, 1.4cm),
    align: (left + horizon, center + horizon, left + horizon, center + horizon),
    size: 8.5pt,
    header: ([TabTransformer], [Nilai], [LightGBM], [Nilai]),
    [Dimensi _embedding_], [64], [_Number of leaves_], [64],
    [Jumlah _Transformer layer_], [4], [_Max depth_], [−1],
    [Jumlah _attention head_], [4], [_Learning rate_], [0,05],
    [_Hidden dimension_ FFN], [128], [Jumlah _estimator_], [500],
    [_Dropout_], [0,2], [_Feature fraction_], [0,8],
    [_Learning rate_ / _Optimizer_], [0,001 / AdamW], [_Bagging fraction_ / _freq._], [0,8 / 5],
    [_Batch size_], [256], [_Min data in leaf_], [20],
    [_Max epoch_ / _early stopping_], [50 / 9], [Regularisasi L2 ($lambda$)], [0,1],
  ),
  caption: [Konfigurasi _hyperparameter_ TabTransformer dan LightGBM (Tabel 5 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-hparam>

== Hasil Deteksi Anomali

Hasil deteksi pada data uji ditampilkan pada @tab-hasil, @fig-cm, dan @fig-hasil. Pada CIC IoT-DIAD 2024, model mendeteksi 2.405.947 serangan dengan benar (TP) dan 78.314 lalu lintas normal (TN), dengan 1.352 _false alarm_ (FP) dan 27.974 serangan yang lolos (FN). Pada CIC IoT 2023, diperoleh 9.679.258 TP, 215.874 TN, 3.764 FP, dan 78.499 FN.

#figure(
  btable(
    columns: (2.8cm, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left + horizon,) + (center + horizon,) * 6,
    size: 8.5pt,
    header: ([Dataset], [Accuracy], [Precision], [Specificity], [Recall], [F1-score], [AUC]),
    [CIC IoT 2023], [99,18], [99,60#super[b]], [98,29], [99,20], [99,58], [0,945],
    [CIC IoT-DIAD 2024], [98,83], [99,94], [98,30], [98,85], [99,39], [0,932],
  ),
  caption: [Hasil deteksi kerangka TabTransformer–LightGBM (dalam %, kecuali AUC). #super[b]Dihitung ulang dari _confusion matrix_ paper, precision CIC IoT 2023 seharusnya 99,96%.],
  supplement: [Tabel],
  kind: table,
) <tab-hasil>

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    img("gambar/fig10_cm_diad.png"),
    img("gambar/fig11_cm_2023.png"),
  ),
  caption: [_Confusion matrix_ kerangka yang diusulkan. Kiri: CIC IoT-DIAD 2024. Kanan: CIC IoT 2023 (Fig. 10 dan Fig. 11 pada paper).],
  supplement: [Gambar],
) <fig-cm>

#figure(
  grid(
    columns: (1.25fr, 1fr),
    column-gutter: 8pt,
    align: horizon,
    img("gambar/fig12_hasil.png"),
    grid(
      rows: 2,
      row-gutter: 4pt,
      img("gambar/fig13_roc_diad.png"),
      img("gambar/fig14_roc_2023.png"),
    ),
  ),
  caption: [Kiri: ringkasan metrik deteksi kedua dataset (Fig. 12). Kanan: kurva ROC pada CIC IoT-DIAD 2024 (atas, AUC 0,932) dan CIC IoT 2023 (bawah, AUC 0,945) (Fig. 13 dan Fig. 14 pada paper).],
  supplement: [Gambar],
) <fig-hasil>

Seluruh metrik berada di atas 98%. Precision yang sangat tinggi (≥ 99,6%) menunjukkan bahwa hampir setiap peringatan merupakan serangan sungguhan. Namun, karena serangan adalah kelas mayoritas, precision tinggi relatif mudah dicapai. Metrik yang lebih penting untuk lalu lintas normal adalah _specificity_ dan _false positive rate_ (FPR). Dengan _specificity_ sekitar 98,3%, FPR sekitar 1,7%, artinya kurang lebih 1 dari 59 _flow_ normal ditandai sebagai serangan. Untuk perangkat pertanian yang mengirim data secara terus-menerus, angka ini masih dapat memicu peringatan palsu dalam jumlah yang tidak kecil. Di sisi lain, recall 98,85% pada DIAD 2024 berarti hampir 28 ribu _flow_ serangan lolos dari deteksi.

Terdapat pula ketidakkonsistenan antara AUC dan metrik lainnya. Model dengan _sensitivity_ sekitar 99% dan _specificity_ sekitar 98% pada satu ambang batas seharusnya memiliki AUC mendekati 0,98–0,99, bukan 0,93–0,945. Paper tidak menjelaskan perbedaan ini, sehingga klaim "strong discriminative power" perlu dibaca dengan hati-hati.

== Perbandingan dengan Model Baseline

Perbandingan dengan _baseline_ yang dijalankan pada kondisi eksperimen yang sama ditampilkan pada @tab-baseline dan @fig-baseline.

#figure(
  text(size: 8pt, table(
    columns: (2.6cm, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left + horizon,) + (center + horizon,) * 8,
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    table.hline(y: 0, stroke: 1pt),
    table.header(
      table.cell(rowspan: 2)[*Model*],
      table.cell(colspan: 4)[*CIC IoT 2023*], table.cell(colspan: 4)[*CIC IoT-DIAD 2024*],
      ..([Acc.], [Prec.], [Rec.], [F1]) * 2,
    ),
    table.hline(y: 1, start: 1, stroke: 0.6pt),
    table.hline(y: 2, stroke: 0.6pt),
    [CNN], [97,25], [98,01], [97,04], [97,52], [97,20], [98,01], [96,80], [97,39],
    [XGBoost], [98,35], [98,79], [97,78], [98,28], [98,02], [99,11], [97,81], [98,45],
    [Random Forest], [98,07], [98,65], [97,60], [98,12], [97,95], [98,67], [97,50], [98,08],
    [TabTransformer], [98,58], [99,03], [98,21], [98,61], [98,25], [99,49], [98,10], [98,79],
    [*Proposed Hybrid*], [*99,18*], [*99,60*], [*99,20*], [*99,58*], [*98,83*], [*99,94*], [*98,85*], [*99,39*],
    table.hline(stroke: 1pt),
  )),
  caption: [Perbandingan kerangka hybrid dengan model _baseline_ (dalam %, Tabel 10 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-baseline>

#figure(
  img("gambar/fig17_baseline.png", width: 92%),
  caption: [Perbandingan kerangka yang diusulkan dengan metode penelitian terdahulu (CNN, CatBoost, LightGBM+MobileNetV2, CNN-DT+DRL, CSK-CNN, LightGBM+CNN, RF/CART, XGBoost/LightGBM, MHDEGAT+OC-SVM, IBSA+LightGBM). Hasil pembanding diambil dari dataset masing-masing penelitian, sehingga tidak sepenuhnya _apple-to-apple_ (Fig. 17 pada paper).],
  supplement: [Gambar],
) <fig-baseline>

Kerangka hybrid unggul pada semua metrik di kedua dataset, tetapi selisihnya kecil. Terhadap _baseline_ terkuat (TabTransformer tunggal), F1-score naik 0,97 poin pada CIC IoT 2023 dan 0,60 poin pada DIAD 2024. Uji-t berpasangan pada F1-score per _fold_ menghasilkan $p = 0,021$ (CIC IoT 2023) dan $p = 0,034$ (DIAD 2024), sehingga peningkatan tersebut signifikan secara statistik pada $alpha = 0,05$. Urutan performa yang konsisten (CNN < Random Forest < XGBoost < TabTransformer < Hybrid) menunjukkan bahwa model yang secara eksplisit memodelkan interaksi antar-fitur memang lebih unggul pada data IoT yang heterogen.

== Studi Ablasi

Studi ablasi menguji kontribusi setiap modul (@tab-ablasi, @fig-ablasi).

#figure(
  btable(
    columns: (3.6cm, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left + horizon,) + (center + horizon,) * 6,
    size: 8.5pt,
    header: ([Konfigurasi], [Dataset], [Acc.], [Prec.], [Spec.], [Rec.], [F1]),
    [Full model], [2023], [99,18], [99,60], [98,29], [99,20], [99,58],
    [Tanpa TabTransformer (LGBM saja)], [2023], [95,62], [94,91], [93,51], [93,82], [94,33],
    [Tanpa SHAP], [2023], [99,18], [99,60], [98,29], [99,20], [99,58],
    [Full model], [DIAD 2024], [98,83], [99,94], [98,30], [98,85], [99,39],
    [Tanpa TabTransformer (LGBM saja)], [DIAD 2024], [94,26], [94,11], [93,78], [93,18], [94,12],
    [Tanpa SHAP], [DIAD 2024], [98,83], [99,94], [98,30], [98,85], [99,39],
  ),
  caption: [Hasil studi ablasi (dalam %, Tabel 12 dan Tabel 13 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-ablasi>

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    img("gambar/fig18_ablasi_2023.png"),
    img("gambar/fig19_ablasi_diad.png"),
  ),
  caption: [Perbandingan kerangka lengkap dengan varian ablasi. Kiri: CIC IoT 2023. Kanan: CIC IoT-DIAD 2024 (Fig. 18 dan Fig. 19 pada paper).],
  supplement: [Gambar],
) <fig-ablasi>

Menghapus TabTransformer menurunkan akurasi sekitar 3,6–4,6 poin dan recall sekitar 5,4–5,7 poin, sehingga representasi kontekstual dari _self-attention_ menjadi komponen yang paling berpengaruh. Menghapus SHAP tidak mengubah metrik deteksi karena SHAP bekerja secara _post-hoc_; kontribusinya ada pada interpretabilitas, bukan akurasi. Namun, hasil ablasi ini perlu dicermati. _Baseline_ XGBoost pada @tab-baseline mencapai akurasi 98,02–98,35%, sedangkan "LGBM saja" pada ablasi hanya 94,26–95,62%. Kedua model berbasis _gradient boosting_ pada fitur yang sama, sehingga selisih sekitar 3 poin ini tidak wajar dan mengindikasikan bahwa varian LightGBM pada ablasi kemungkinan tidak di-_tuning_ seoptimal _baseline_. Akibatnya, kontribusi TabTransformer berpotensi terlihat lebih besar daripada yang sebenarnya. Jika dibandingkan dengan XGBoost, peningkatan dari hybrid hanya sekitar 0,8 poin akurasi.

== Ketahanan dan Generalisasi

Untuk menjawab kekhawatiran _overfitting_, penulis melakukan _5-fold cross-validation_, evaluasi lintas-dataset, dan validasi eksternal pada UNSW-NB15 (@tab-cv, @tab-cross).

#grid(
  columns: (1fr, 1.25fr),
  column-gutter: 10pt,
  [
    #figure(
      btable(
        columns: (1.6cm, 1fr, 1fr),
        align: (left + horizon, center + horizon, center + horizon),
        size: 8pt,
        header: ([Metrik], [CIC IoT 2023], [DIAD 2024]),
        [Accuracy], [99,07 ± 0,11], [98,82 ± 0,18],
        [Precision], [99,52 ± 0,15], [99,90 ± 0,12],
        [Recall], [99,10 ± 0,18], [98,80 ± 0,20],
        [F1-score], [99,31 ± 0,14], [99,35 ± 0,16],
      ),
      caption: [Hasil _5-fold cross-validation_ (mean ± std, %).],
      supplement: [Tabel],
      kind: table,
    ) <tab-cv>
  ],
  [
    #figure(
      btable(
        columns: (1.5cm, 1.5cm, 1fr, 1fr, 1fr),
        align: (left + horizon, left + horizon, center + horizon, center + horizon, center + horizon),
        size: 8pt,
        header: ([Latih], [Uji], [Acc.], [Rec.], [F1]),
        [2023], [2023], [99,18], [99,20], [99,58],
        [2023], [DIAD], [93,52], [92,81], [93,97],
        [DIAD], [DIAD], [98,83], [98,85], [99,48],
        [DIAD], [2023], [92,86], [91,97], [93,31],
        [UNSW-NB15], [UNSW-NB15], [99,84], [98,89], [96,86],
      ),
      caption: [Evaluasi lintas-dataset dan validasi eksternal (%).],
      supplement: [Tabel],
      kind: table,
    ) <tab-cross>
  ],
)

#figure(
  img("gambar/fig20_loss.png", width: 62%),
  caption: [Kurva _loss_ latih dan validasi TabTransformer; konvergen pada epoch 27–39 dengan _early stopping_ (Fig. 20 pada paper).],
  supplement: [Gambar],
) <fig-loss>

Simpangan baku antar-_fold_ yang kecil (≤ 0,20) dan interval kepercayaan 95% yang sempit menunjukkan bahwa hasil stabil terhadap variasi partisi data. Evaluasi lintas-dataset merupakan bukti generalisasi yang paling jujur: performa turun ke kisaran 92–94% ketika model diuji pada dataset dengan komposisi serangan berbeda (DDoS-dominan vs DoS-dominan). Penurunan ini wajar dan menunjukkan bahwa model tidak hanya menghafal tanda tangan satu dataset. Namun, hal ini juga berarti performa di atas 98% kemungkinan besar tidak akan tercapai pada lahan pertanian nyata yang distribusi lalu lintasnya berbeda. Pada UNSW-NB15, recall (98,89%) dan _specificity_ (99,86%) tetap tinggi, tetapi precision turun ke 94,92%, yang menandakan lebih banyak _false alarm_ pada lingkungan yang lebih heterogen.

== Analisis Explainability (SHAP)

Analisis SHAP global menunjukkan bahwa keputusan model terutama didorong oleh fitur statistik _flow_ dan header protokol (@tab-shap, @fig-shap).

#figure(
  btable(
    columns: (0.8cm, 3cm, 2.6cm, 1.6cm, 1.2cm, 1fr),
    align: (center + horizon, left + horizon, left + horizon, left + horizon, center + horizon, left + horizon),
    size: 8pt,
    header: ([No], [Fitur], [Kategori], [Asal], [SHAP], [Interpretasi]),
    [1], [Flow Duration], [Statistical/Flow], [DIAD], [0,142], [_Flow_ panjang pada DoS/_slow attack_],
    [2], [Packet Length Mean], [Statistical/Flow], [DIAD], [0,126], [Payload tidak wajar (exfiltration/flooding)],
    [3], [Time_To_Live], [Protocol/Header], [2023], [0,118], [Spoofing / routing abnormal],
    [4], [SYN Flag Count], [Flag Counters], [Keduanya], [0,112], [Inisiasi koneksi abnormal (flooding)],
    [5], [Flow Bytes/s], [Extra Flow], [DIAD], [0,105], [Anomali volumetrik],
    [6], [Header_Length], [Protocol/Header], [2023], [0,099], [Paket rekayasa vs normal],
    [7], [ACK Flag Count], [Flag Counters], [Keduanya], [0,093], [Pembeda perilaku transport normal],
    [8], [Average Packet Size], [Statistical/Flow], [DIAD], [0,089], [Scanning dan probing],
    [9], [IAT Mean], [Statistical], [2023], [0,085], [_Flow bursty_ vs _stealthy_],
    [10], [Subflow Fwd Bytes], [Extra Flow], [DIAD], [0,081], [Komunikasi mirip botnet],
  ),
  caption: [Sepuluh fitur teratas berdasarkan rata-rata nilai SHAP (diringkas dari Tabel 9 paper).],
  supplement: [Tabel],
  kind: table,
) <tab-shap>

#figure(
  grid(
    columns: (1.15fr, 1fr),
    column-gutter: 8pt,
    align: horizon,
    img("gambar/fig15_shap_top15.png"),
    img("gambar/fig16_shap_kategori.png"),
  ),
  caption: [Kiri: 15 fitur teratas berdasarkan rata-rata nilai SHAP. Kanan: distribusi kontribusi SHAP per kategori fitur (Fig. 15 dan Fig. 16 pada paper).],
  supplement: [Gambar],
) <fig-shap>

Kategori Statistical/Flow menyumbang porsi terbesar (25,8%), diikuti Extra Flow Attributes (18,6%), Protocol/Header (15,7%), Statistical Metrics (15,4%), Flag Counters (14,8%), dan Service Indicators (9,7%). Hal ini menunjukkan bahwa pola temporal dan volumetrik merupakan sinyal utama anomali, sedangkan atribut protokol dan _flag_ TCP memberi sinyal pelengkap untuk serangan _spoofing_ dan _flooding_. Analisis interaksi SHAP juga menunjukkan bahwa Protocol Type secara tunggal memiliki daya pisah yang rendah, tetapi bila dikombinasikan dengan Packet Length Mean yang abnormal, probabilitas serangan meningkat tajam. Temuan ini konsisten dengan klaim bahwa TabTransformer menangkap interaksi kontekstual antar-fitur. Kelemahannya, SHAP dihitung pada LightGBM yang menerima _embedding_ hasil TabTransformer, sehingga pemetaan kembali nilai SHAP ke nama fitur asli (misalnya "Flow Duration") tidak dijelaskan dalam paper.

== Analisis Pengaruh Metode terhadap Hasil Eksperimen

Secara keseluruhan, metode hybrid memberikan pengaruh positif terhadap hasil deteksi anomali melalui tiga mekanisme. *Pertama*, TabTransformer memperkaya representasi data tabular heterogen dengan _embedding_ kontekstual. Komponen ini merupakan kontributor terbesar menurut ablasi (+3,6 sampai +4,6 poin akurasi) dan menjadi pembeda utama terhadap model berbasis pohon biasa. *Kedua*, pemisahan representasi dan klasifikasi membuat biaya komputasi _attention_ hanya dibayar saat pelatihan (sekitar 18 detik per epoch, 4,7 juta parameter), sedangkan inferensi oleh LightGBM tetap cepat (3,5 ms per instans) dan cocok untuk penerapan di _cloud_. *Ketiga*, SHAP tidak memengaruhi akurasi tetapi menambah nilai operasional karena mengungkap pola anomali yang dapat ditindaklanjuti, misalnya kombinasi SYN tinggi dan ACK rendah pada _flooding_, serta penyebab _false positive_ berupa lalu lintas normal yang bersifat _bursty_.

Meski demikian, besarnya pengaruh metode perlu disikapi secara kritis. (1) Peningkatan terhadap _baseline_ yang di-_tuning_ dengan baik hanya sekitar 0,6–1 poin F1-score, sehingga keunggulan utama kerangka ini terletak pada kombinasi akurasi, kecepatan, dan interpretabilitas, bukan lonjakan akurasi. (2) Terdapat beberapa inkonsistensi numerik, yaitu jumlah sampel serangan, precision CIC IoT 2023, AUC yang lebih rendah dari yang diharapkan, dan "LGBM saja" yang jauh di bawah XGBoost, sehingga reprodusibilitas perlu diverifikasi. (3) Klaim relevansi untuk _smart farming_ belum diuji langsung karena kedua dataset berasal dari _testbed_ IoT umum milik CIC, bukan lalu lintas lahan pertanian nyata. (4) Formulasi biner tidak membedakan jenis serangan, sehingga analisis forensik dan prioritas respons tetap memerlukan tahap lanjutan. (5) Model belum mendukung _online/continual learning_ untuk beradaptasi terhadap serangan baru. Penulis sendiri mengakui keterbatasan nomor 3–5 dan mengusulkan pengembangan ke arah deteksi dua tahap multikelas, optimasi untuk perangkat _edge_, serta validasi pada dataset lain seperti IoT-23.

// ============================================================
#pagebreak()

#heading(numbering: none)[Daftar Pustaka]

#[
  #set par(first-line-indent: 0pt, hanging-indent: 1.25cm, justify: false, leading: 0.65em, spacing: 0.9em)
  #set text(size: 11pt)

  M L, A. E. M., S, P., Thirumalaisamy, M., Kaliyaperumal, P., Balusamy, B., & Benedetto, F. (2026). A novel hybrid TabTransformer–LightGBM framework for explainable intrusion detection in smart farming IoT networks. _Computers and Electrical Engineering, 138_, 111344. https://doi.org/10.1016/j.compeleceng.2026.111344
]
