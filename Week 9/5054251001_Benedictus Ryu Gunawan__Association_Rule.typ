
// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Laporan Analisis Keranjang Pasar dengan Association Rule Mining pada Dataset Online Retail",
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
  #text(size: 18pt, weight: "bold")[TUGAS - WEEK 9]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN ANALISIS KERANJANG PASAR DENGAN ASSOCIATION RULE MINING PADA DATASET ONLINE RETAIL]
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

Association rule mining adalah teknik untuk menemukan pola keterkaitan antar item dalam data transaksi. Dalam konteks ritel, teknik ini dikenal sebagai market basket analysis: dari daftar produk yang dibeli pada setiap invoice, algoritma mencari itemset yang sering muncul bersama, lalu menurunkan aturan berbentuk X -> Y. Tiga ukuran utama yang dipakai adalah support (seberapa sering itemset muncul), confidence (seberapa besar peluang Y dibeli jika X dibeli), dan lift (seberapa kuat asosiasi dibandingkan kebetulan).

Dataset Online Retail dari UCI Machine Learning Repository berisi 541.909 baris transaksi pengecer UK pada Desember 2010 sampai Desember 2011. Dataset ini memiliki banyak invoice, variasi nama produk, pembatalan transaksi, quantity negatif, dan baris non-produk. Karena itu pembersihan data dan pembentukan transaksi berbasis invoice menjadi tahap penting sebelum algoritma diterapkan. Pada laporan ini dipakai FP-Growth karena jumlah produk yang besar membuat pembangkitan kandidat Apriori pada support rendah menjadi mahal.

== Tujuan

Tujuan praktikum ini adalah:

1. Mengimpor dan memahami struktur dataset Online Retail.
2. Membersihkan data serta menampilkan jumlah baris dan invoice sebelum dan sesudah pembersihan.
3. Membentuk transaksi berbasis invoice dan mengubahnya menjadi matriks one-hot.
4. Menerapkan FP-Growth untuk menemukan frequent itemset dan aturan asosiasi.
5. Mengevaluasi aturan dengan support, confidence, dan lift, lalu menginterpretasikan pola untuk bisnis ritel.

Alur kerja mengikuti notebook `5054251001_Benedictus Ryu Gunawan__Association_Rule.ipynb`. Seluruh gambar dan tabel pada laporan ini dihasilkan oleh notebook tersebut dan tersimpan pada folder `output/`.

= Deskripsi Dataset

Dataset `Online Retail.xlsx` terdiri dari 541.909 baris dan 8 kolom. Satu baris merepresentasikan satu baris item pada invoice, bukan satu transaksi unik. Jumlah invoice adalah 25.900 dan jumlah Description unik adalah 4.223 sebelum pembersihan. Periode transaksi berlangsung dari 1 Desember 2010 sampai 9 Desember 2011, dan 91,43\% baris berasal dari United Kingdom.

#figure(
  table(
    columns: (2fr, 3fr),
    stroke: 0.5pt,
    table.header([*Atribut*], [*Nilai*]),
    [Jumlah baris], [541.909],
    [Jumlah kolom], [8],
    [Jumlah invoice], [25.900],
    [Jumlah Description unik], [4.223],
    [Periode transaksi], [1 Desember 2010 sampai 9 Desember 2011],
    [Negara], [38 negara, 91,43\% United Kingdom],
    [Description kosong], [1.454 baris (0,27\%)],
    [CustomerID kosong], [135.080 baris (24,93\%)],
  ),
  caption: [Ringkasan dataset Online Retail sebelum pembersihan]
)

#figure(
  table(
    columns: (1.3fr, 1.1fr, 4fr),
    stroke: 0.5pt,
    table.header([*Kolom*], [*Tipe*], [*Deskripsi*]),
    [InvoiceNo], [String], [Nomor invoice; awalan C menandakan pembatalan],
    [StockCode], [String], [Kode produk],
    [Description], [String], [Nama produk],
    [Quantity], [Integer], [Jumlah unit pada baris transaksi],
    [InvoiceDate], [Datetime], [Tanggal dan waktu transaksi],
    [UnitPrice], [Float], [Harga satuan],
    [CustomerID], [Float], [ID pelanggan; banyak nilai kosong],
    [Country], [String], [Negara pelanggan],
  ),
  caption: [Struktur kolom dataset Online Retail]
)

CustomerID tidak dipakai dalam analisis karena 24,93\% baris tidak memiliki ID pelanggan dan association rule tidak memerlukan identitas pelanggan. Description kosong harus dihapus karena item tidak dapat diidentifikasi. Missing values pada kolom lain tidak ditemukan.

#figure(
  image("output/missing_values.png", width: 82%),
  caption: [Jumlah nilai kosong per kolom pada data mentah. CustomerID mendominasi dengan 135.080 nilai kosong; Description hanya 1.454 nilai kosong.],
) <fig-missing>

= Eksplorasi dan Pembersihan Data

== Kolom yang Relevan

Kolom yang dipakai untuk association rule adalah `InvoiceNo` sebagai identitas transaksi, `Description` sebagai nama item, `Quantity` untuk memastikan baris adalah pembelian, dan `StockCode` untuk menyaring baris non-produk. `InvoiceDate` dan `UnitPrice` dipakai untuk konteks, bukan untuk pembentukan itemset. `CustomerID` tidak dipakai karena alasan yang sudah dijelaskan.

== Tahapan Pembersihan

Pembersihan dilakukan bertahap:

+ Menyeragamkan `Description` menjadi huruf kapital dan menghapus spasi berlebih, serta merapikan `InvoiceNo` dan `StockCode`.
+ Menghapus baris dengan `Description` kosong.
+ Menghapus invoice yang dibatalkan, yaitu `InvoiceNo` yang diawali huruf C.
+ Menghapus baris dengan `Quantity` negatif atau nol.
+ Menghapus baris non-produk seperti postage, manual, carriage, bank charges, gift voucher, dan kode stok layanan.
+ Menghapus duplikat baris.

Langkah 5 dan 6 adalah tambahan agar aturan yang dihasilkan benar-benar mencerminkan produk ritel, bukan biaya pengiriman atau administrasi.

#figure(
  table(
    columns: (2.5fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    stroke: 0.5pt,
    table.header([*Tahap*], [*Baris*], [*Invoice*], [*Baris dihapus*], [*Invoice hilang*]),
    [Data mentah], [541.909], [25.900], [0], [0],
    [Hapus Description kosong], [540.455], [24.446], [1.454], [1.454],
    [Hapus invoice batal (C)], [531.167], [20.610], [9.288], [3.836],
    [Hapus Quantity <= 0], [530.693], [20.136], [474], [474],
    [Hapus baris non-produk], [528.335], [19.954], [2.358], [182],
    [Hapus duplikat], [523.109], [19.954], [5.226], [0],
  ),
  caption: [Jumlah baris dan invoice sebelum dan sesudah setiap tahap pembersihan]
)

#figure(
  image("output/cleaning_funnel.png", width: 100%),
  caption: [Dampak pembersihan per tahap. Pembatalan invoice menghapus baris terbanyak, sedangkan duplikat tidak mengubah jumlah invoice.],
) <fig-cleaning>

Pembersihan wajib (langkah 2 sampai 4) menurunkan 541.909 baris menjadi 530.693 baris dan 20.136 invoice. Sebanyak 1.454 invoice hilang karena seluruh barisnya tidak memiliki Description, dan 3.836 invoice dibatalkan. Setelah filter non-produk dan duplikat, data final berisi 523.109 baris, 19.954 invoice, dan 4.045 produk. Filter non-produk menghapus 2.358 baris dan 182 invoice yang hanya berisi layanan. Duplikat sebanyak 5.226 baris tidak mengubah jumlah invoice karena itemset dibentuk dari himpunan produk unik per invoice.

== Distribusi Ukuran Keranjang

Ukuran keranjang dihitung dari jumlah Description unik per invoice. Distribusinya miring ke kanan: median 15 produk, rata-rata 25,94 produk, dan nilai maksimum 1.106 produk. Sebanyak 1.662 invoice (8,33\%) hanya berisi satu produk sehingga tidak dapat membentuk aturan asosiasi, tetapi tetap dihitung dalam denominator support karena merepresentasikan transaksi nyata.

#figure(
  image("output/invoice_size_distribution.png", width: 100%),
  caption: [Distribusi jumlah produk unik per invoice dan ECDF ukuran keranjang. Median 15 produk; 90\% invoice berisi paling banyak 52 produk.],
) <fig-invoice-size>

== Produk Terpopuler

Produk terpopuler adalah WHITE HANGING HEART T-LIGHT HOLDER (2.260 invoice, 11,33\%), JUMBO BAG RED RETROSPOT (2.092 invoice, 10,48\%), dan REGENCY CAKESTAND 3 TIER (1.989 invoice, 9,97\%). Sepuluh produk teratas hanya mencakup 3,14\% dari seluruh pasangan invoice-produk, dan dibutuhkan 1.308 produk untuk mencakup 80\% pasangan. Ini menunjukkan distribusi long tail yang kuat.

#figure(
  table(
    columns: (3fr, 1fr, 1fr),
    align: (left, right, right),
    stroke: 0.5pt,
    table.header([*Produk*], [*Invoice*], [*Support*]),
    [WHITE HANGING HEART T-LIGHT HOLDER], [2.260], [11,33],
    [JUMBO BAG RED RETROSPOT], [2.092], [10,48],
    [REGENCY CAKESTAND 3 TIER], [1.989], [9,97],
    [PARTY BUNTING], [1.686], [8,45],
    [LUNCH BAG RED RETROSPOT], [1.564], [7,84],
    [ASSORTED COLOUR BIRD ORNAMENT], [1.455], [7,29],
    [SET OF 3 CAKE TINS PANTRY DESIGN], [1.385], [6,94],
    [PACK OF 72 RETROSPOT CAKE CASES], [1.320], [6,62],
    [LUNCH BAG  BLACK SKULL.], [1.273], [6,38],
    [NATURAL SLATE HEART CHALKBOARD], [1.249], [6,26],
  ),
  caption: [Sepuluh produk dengan jumlah invoice terbanyak]
)

#figure(
  image("output/top_products.png", width: 100%),
  caption: [Produk terpopuler dan kurva kumulatif pasangan invoice-produk. Distribusi produk sangat panjang; 1.308 produk diperlukan untuk mencapai 80\% pasangan.],
) <fig-top-products>

= Persiapan Data untuk Association Rule

Data baris demi baris diubah menjadi transaksi berbasis invoice. Untuk setiap `InvoiceNo`, daftar `Description` diubah menjadi himpunan unik agar produk yang sama tidak dihitung dua kali dalam satu invoice. Contoh lima invoice pertama ditampilkan pada tabel berikut.

#figure(
  table(
    columns: (0.8fr, 0.7fr, 4fr),
    align: (left, right, left),
    stroke: 0.5pt,
    table.header([*Invoice*], [*Jumlah*], [*Contoh produk*]),
    [536365], [7], [CREAM CUPID HEARTS COAT HANGER; GLASS STAR FROSTED T-LIGHT HOLDER; KNITTED UNION FLAG HOT WATER BOTTLE],
    [536366], [2], [HAND WARMER RED POLKA DOT; HAND WARMER UNION JACK],
    [536367], [12], [ASSORTED COLOUR BIRD ORNAMENT; BOX OF 6 ASSORTED COLOUR TEASPOONS; BOX OF VINTAGE ALPHABET BLOCKS],
    [536368], [4], [BLUE COAT RACK PARIS FASHION; JAM MAKING SET WITH JARS; RED COAT RACK PARIS FASHION],
    [536369], [1], [BATH BUILDING BLOCK WORD],
  ),
  caption: [Contoh transaksi berbasis invoice setelah pembersihan]
)

Hasilnya adalah 19.954 transaksi dengan rata-rata 25,94 produk unik per transaksi. Transaksi kemudian diubah menjadi matriks one-hot berukuran 19.954 x 4.045. Setiap baris adalah invoice, setiap kolom adalah produk, nilai 1 berarti produk dibeli pada invoice tersebut, dan 0 berarti tidak. Kepadatan matriks hanya 0,6412\%, sehingga matriks bersifat sangat sparse. Matriks ini menjadi input FP-Growth.

#figure(
  table(
    columns: (2fr, 2fr),
    stroke: 0.5pt,
    table.header([*Properti*], [*Nilai*]),
    [Jumlah transaksi], [19.954],
    [Jumlah produk], [4.045],
    [Shape matriks], [19.954 x 4.045],
    [Kepadatan], [0,6412\%],
    [Ukuran memori], [80,7 MB],
  ),
  caption: [Ringkasan matriks one-hot untuk association rule]
)

= Penerapan Algoritma Association Rule

== Pemilihan FP-Growth

Algoritma yang dipakai adalah FP-Growth. FP-Growth membangun FP-tree untuk memadatkan transaksi sehingga tidak perlu membangkitkan kandidat secara eksplisit seperti Apriori. Pada dataset ini terdapat 4.045 produk; Apriori dengan support 1\% mengalami ledakan kandidat dan tidak praktis dijalankan. FP-Growth menyelesaikan pencarian dalam hitungan detik. Sebagai validasi, Apriori pada support 2\% menghasilkan 376 itemset dan 30 aturan yang identik dengan FP-Growth, dengan waktu 1,64 detik dibandingkan 1,48 detik untuk FP-Growth.

== Parameter Awal

Parameter awal mengikuti tugas: minimum support 0,01 dan minimum confidence 0,5. Kombinasi ini menghasilkan 1.820 frequent itemset dan 816 aturan. Jumlah 816 aturan terlalu banyak untuk ditinjau dan banyak aturan yang merupakan cermin dari aturan lain, misalnya A -> B dan B -> A, atau permutasi dari itemset yang sama. Banyak pula aturan yang berasal dari itemset berukuran kecil dengan support tepat di atas threshold.

== Penyesuaian Parameter

Parameter dinaikkan secara bertahap. Tabel dan grafik berikut menunjukkan trade-off antara minimum support, minimum confidence, jumlah frequent itemset, dan jumlah aturan.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    align: (center, right, right, right, right),
    stroke: 0.5pt,
    table.header([*Support*], [*Itemset*], [*Rules c=0,5*], [*Rules c=0,6*], [*Rules c=0,7*]),
    [1,0\%], [1.820], [816], [484], [261],
    [1,5\%], [701], [182], [97], [45],
    [2,0\%], [376], [60], [30], [13],
    [2,5\%], [223], [37], [21], [10],
    [3,0\%], [140], [13], [9], [4],
  ),
  caption: [Sensitivitas parameter. Jumlah itemset hanya bergantung pada support; jumlah aturan bergantung pada support dan confidence.]
)

#figure(
  image("output/parameter_sensitivity.png", width: 100%),
  caption: [Kurva sensitivitas parameter. Garis putus-putus menandai support 2\%; titik final berada pada 30 aturan untuk confidence 0,6.],
) <fig-sensitivity>

Pada support 0,015 dan confidence 0,6 masih ada 97 aturan; pada support 0,02 dan confidence 0,6 tersisa 30 aturan; pada support 0,03 hanya tersisa 9 aturan. Support 0,02 dipilih karena masih mencakup minimal 399 invoice (2\% dari 19.954) dan confidence 0,6 menjaga aturan tetap cukup kuat tanpa memangkas terlalu banyak pola. Kombinasi ini memberi daftar aturan yang cukup ringkas untuk dianalisis dan diimplementasikan.

== Model Final

Kombinasi final minimum support 0,02 dan minimum confidence 0,6 menghasilkan 376 frequent itemset dan 30 aturan asosiasi. Dari 376 itemset, 295 berupa satu produk, 78 berupa pasangan produk, dan 3 berupa triplet produk. Tidak ada itemset dengan empat produk atau lebih pada threshold ini.

#figure(
  table(
    columns: (1fr, 1fr, 3fr),
    align: (center, right, left),
    stroke: 0.5pt,
    table.header([*Ukuran*], [*Jumlah*], [*Contoh*]),
    [1], [295], [WHITE HANGING HEART T-LIGHT HOLDER],
    [2], [78], [GREEN REGENCY TEACUP AND SAUCER + ROSES REGENCY TEACUP AND SAUCER],
    [3], [3], [PINK + GREEN + ROSES REGENCY TEACUP AND SAUCER],
  ),
  caption: [Distribusi ukuran frequent itemset pada support 2\%]
)

#figure(
  image("output/itemset_size.png", width: 62%),
  caption: [Sebagian besar frequent itemset berukuran satu produk; hanya tiga itemset berukuran tiga produk.],
) <fig-itemset-size>

Sepuluh pasangan produk dengan support tertinggi ditampilkan pada tabel berikut. Pasangan terbanyak berasal dari varian tas jumbo, cangkir Regency, kotak makan, jam alarm, dan paper chain kit.

#figure(
  table(
    columns: (4fr, 1fr),
    align: (left, right),
    stroke: 0.5pt,
    table.header([*Pasangan produk*], [*Support*]),
    [JUMBO BAG PINK POLKADOT + JUMBO BAG RED RETROSPOT], [4,13\%],
    [GREEN REGENCY TEACUP AND SAUCER + ROSES REGENCY TEACUP AND SAUCER], [3,85\%],
    [JUMBO BAG RED RETROSPOT + JUMBO STORAGE BAG SUKI], [3,63\%],
    [JUMBO BAG RED RETROSPOT + JUMBO SHOPPER VINTAGE RED PAISLEY], [3,41\%],
    [LUNCH BAG BLACK SKULL. + LUNCH BAG RED RETROSPOT], [3,21\%],
    [ALARM CLOCK BAKELIKE GREEN + ALARM CLOCK BAKELIKE RED], [3,21\%],
    [GREEN REGENCY TEACUP AND SAUCER + PINK REGENCY TEACUP AND SAUCER], [3,17\%],
    [LUNCH BAG PINK POLKADOT + LUNCH BAG RED RETROSPOT], [3,04\%],
    [PINK REGENCY TEACUP AND SAUCER + ROSES REGENCY TEACUP AND SAUCER], [3,00\%],
    [JUMBO BAG BAROQUE BLACK WHITE + JUMBO BAG RED RETROSPOT], [2,93\%],
  ),
  caption: [Sepuluh pasangan produk dengan support tertinggi]
)

= Evaluasi Aturan Asosiasi

== Ukuran Evaluasi

Support mengukur proporsi invoice yang mengandung antecedent dan consequent sekaligus. Confidence mengukur proporsi invoice dengan antecedent yang juga mengandung consequent. Lift mengukur seberapa lebih sering consequent muncul ketika antecedent ada dibandingkan kemunculannya secara umum. Lift 1 berarti independen, lift > 1 berarti asosiasi positif, dan lift < 1 berarti asosiasi negatif.

#figure(
  table(
    columns: (1fr, 2.2fr, 3fr),
    stroke: 0.5pt,
    table.header([*Metrik*], [*Rumus*], [*Interpretasi*]),
    [Support], [P(X dan Y)], [Proporsi invoice yang mengandung X dan Y],
    [Confidence], [P(Y jika X) = support(X dan Y) / support(X)], [Peluang Y dibeli jika X sudah dibeli],
    [Lift], [confidence / support(Y)], [> 1 asosiasi positif, = 1 independen, < 1 negatif],
    [Leverage], [support(X dan Y) - support(X) support(Y)], [Selisih support gabungan dari kondisi independen],
    [Conviction], [(1 - support(Y)) / (1 - confidence)], [Kekuatan implikasi aturan],
  ),
  caption: [Ukuran evaluasi aturan asosiasi]
)

== Aturan yang Dihasilkan

Aturan diurutkan berdasarkan lift, lalu confidence. Sepuluh aturan teratas ditampilkan pada tabel berikut. Seluruh 30 aturan ada pada lampiran dan pada file `output/rules_final.csv`.

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (0.35fr, 4fr, 0.7fr, 0.8fr, 0.6fr),
      align: (center, left, right, right, right),
      stroke: 0.5pt,
      table.header([*No*], [*Aturan*], [*Support*], [*Confidence*], [*Lift*]),
      [1], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,708], [18,38],
    [2], [GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER], [2,72], [0,706], [18,38],
    [3], [PINK REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [2,72], [0,905], [17,79],
    [4], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [3,17], [0,826], [16,25],
    [5], [GREEN REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER], [3,17], [0,624], [16,25],
    [6], [GREEN REGENCY TEACUP AND SAUCER, PINK REGENCY TEACUP AND SAUCER -> ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,856], [16,03],
    [7], [GARDENERS KNEELING PAD CUP OF TEA -> GARDENERS KNEELING PAD KEEP CALM], [2,74], [0,720], [15,74],
    [8], [REGENCY CAKESTAND 3 TIER, ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [2,04], [0,777], [15,28],
    [9], [GREEN REGENCY TEACUP AND SAUCER, REGENCY CAKESTAND 3 TIER -> ROSES REGENCY TEACUP AND SAUCER], [2,04], [0,802], [15,00],
    [10], [PINK REGENCY TEACUP AND SAUCER -> ROSES REGENCY TEACUP AND SAUCER], [3,00], [0,782], [14,64],
    )
  ],
  caption: [Sepuluh aturan asosiasi teratas berdasarkan lift]
)

#figure(
  image("output/support_confidence_scatter.png", width: 90%),
  caption: [Sebaran support dan confidence untuk 30 aturan final. Warna menunjukkan lift; aturan dengan lift tinggi berada di area support rendah sampai menengah.],
) <fig-scatter>

== Tiga Aturan Terbaik

Jika diurutkan murni berdasarkan lift, tiga aturan teratas seluruhnya berasal dari itemset tiga cangkir Regency. Ketiganya adalah permutasi dari itemset yang sama sehingga dibaca sebagai satu pola koleksi warna.

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (0.35fr, 4fr, 0.7fr, 0.8fr, 0.6fr),
      align: (center, left, right, right, right),
      stroke: 0.5pt,
      table.header([*No*], [*Aturan*], [*Support*], [*Confidence*], [*Lift*]),
      [1], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,708], [18,38],
    [2], [GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER], [2,72], [0,706], [18,38],
    [3], [PINK REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [2,72], [0,905], [17,79],
    )
  ],
  caption: [Tiga aturan teratas berdasarkan lift]
)

Interpretasi ketiga aturan tersebut adalah sebagai berikut.

+ *PINK REGENCY TEACUP AND SAUCER -> GREEN + ROSES REGENCY TEACUP AND SAUCER.* Sebanyak 70,76\% invoice yang mengandung cangkir pink juga mengandung cangkir green dan roses. Support 2,72\% berarti pola ini muncul pada 542 invoice. Lift 18,38 berarti kombinasi ini 18,38 kali lebih sering daripada jika ketiga warna dibeli secara independen.
+ *GREEN + ROSES REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER.* Sebanyak 70,57\% invoice dengan green dan roses juga mengandung pink. Arah ini hampir simetris dengan aturan pertama, dengan support dan lift yang sama.
+ *PINK + ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER.* Sebanyak 90,48\% invoice dengan pink dan roses juga mengandung green. Aturan ini memiliki confidence tertinggi di antara ketiganya, sehingga green dapat diposisikan sebagai varian pelengkap yang paling kuat ketika dua warna lain sudah ada.

Karena ketiga aturan tersebut redundan, untuk rekomendasi praktis dipilih tiga pola berbeda dengan lift tertinggi. Tabel berikut merangkum pola tersebut.

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (1.1fr, 4fr, 0.7fr, 0.8fr, 0.6fr),
      align: (left, left, right, right, right),
      stroke: 0.5pt,
      table.header([*Pola*], [*Aturan*], [*Support*], [*Confidence*], [*Lift*]),
      [Regency teacup], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,708], [18,38],
    [Garden kneeler], [GARDENERS KNEELING PAD CUP OF TEA -> GARDENERS KNEELING PAD KEEP CALM], [2,74], [0,720], [15,74],
    [Lunch box], [DOLLY GIRL LUNCH BOX -> SPACEBOY LUNCH BOX], [2,70], [0,633], [14,03],
    [Jumbo bag], [JUMBO BAG PEARS -> JUMBO BAG APPLES], [2,03], [0,682], [13,92],
    )
  ],
  caption: [Tiga pola berbeda dengan lift tertinggi setelah aturan cermin digabung]
)

*Pola Regency teacup set.* Pembeli cangkir pink memiliki peluang 70,76\% membeli green dan roses sekaligus, 18,38 kali lebih tinggi daripada peluang acak. Rekomendasi bisnisnya adalah bundling tiga warna, menampilkan ketiganya berdampingan, dan menawarkan diskon set.

*Pola garden kneeler.* Pembeli desain CUP OF TEA memiliki peluang 72,03\% membeli desain KEEP CALM, dengan lift 15,74. Rekomendasi bisnisnya adalah memajang kedua desain berdekatan sebagai pilihan desain, bukan sebagai produk pengganti.

*Pola lunch box anak.* Pembeli DOLLY GIRL LUNCH BOX memiliki peluang 63,29\% membeli SPACEBOY LUNCH BOX, dengan lift 14,03. Rekomendasi bisnisnya adalah cross-sell untuk keluarga dengan anak laki-laki dan perempuan, atau paket hadiah.

*Pola jumbo bag.* Pembeli JUMBO BAG PEARS memiliki peluang 68,24\% membeli JUMBO BAG APPLES, dengan lift 13,92. Pola serupa muncul pada varian Charlotte bag, warna alarm clock, dan paper chain kit. Secara keseluruhan, pola yang dominan adalah pembelian beberapa varian desain dari produk yang sama, bukan cross-sell antar kategori yang berbeda.

== Implikasi Bisnis

Hasil ini dapat dipakai untuk rekomendasi produk, penataan rak, bundling, dan perencanaan stok. Aturan dengan lift di atas 10 dan support di atas 2\% layak diprioritaskan karena cukup kuat dan cukup sering muncul. Contoh implementasinya adalah paket tiga warna cangkir Regency, paket dua desain garden kneeler, dan rekomendasi lunch box pasangan saat pelanggan melihat salah satu desain.

Namun, aturan asosiasi hanya menunjukkan co-purchase, bukan hubungan kausal. Support 2\% sampai 4\% berarti pola ini berlaku pada sebagian kecil invoice, sehingga sebaiknya diprioritaskan untuk pelanggan yang sudah memiliki antecedent. Dataset berasal dari satu pengecer UK pada 2010-2011, tidak memuat margin atau stok, dan 25\% baris tidak memiliki CustomerID. Validasi tambahan dengan uji A/B atau data terbaru diperlukan sebelum keputusan komersial.

= Kesimpulan

Dataset Online Retail berhasil dibersihkan dari 541.909 baris menjadi 523.109 baris dan 19.954 invoice. Setelah one-hot encoding, FP-Growth dengan support 0,02 dan confidence 0,6 menghasilkan 376 frequent itemset dan 30 aturan asosiasi. Pola terkuat adalah pembelian beberapa varian desain dari produk yang sama, terutama tiga warna cangkir Regency (lift 18,38), dua desain garden kneeler (lift 15,74), dan dua desain lunch box (lift 14,03). Untuk implementasi, prioritaskan bundling varian dan rekomendasi yang dipersonalisasi berdasarkan isi keranjang, lalu ukur dampaknya dengan eksperimen.

== Saran Pengembangan

+ Memperbarui analisis dengan data transaksi yang lebih baru dan periode yang lebih panjang agar pola tetap relevan.
+ Menguji dampak bundling dan rekomendasi melalui eksperimen A/B, bukan hanya dari nilai lift.
+ Menambahkan informasi margin, stok, dan kategori produk untuk memprioritaskan aturan yang paling menguntungkan.
+ Membandingkan FP-Growth dengan algoritma lain seperti Eclat atau closed itemset, serta metrik tambahan seperti cosine dan Kulczynski.

#pagebreak()
= Lampiran: 30 Aturan Asosiasi

#figure(
  text(size: 7pt)[
    #table(
      columns: (0.35fr, 4fr, 0.7fr, 0.8fr, 0.6fr),
      align: (center, left, right, right, right),
      inset: 2.5pt,
      stroke: 0.5pt,
      table.header([*No*], [*Aturan*], [*Support*], [*Confidence*], [*Lift*]),
      [1], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,708], [18,38],
    [2], [GREEN REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER], [2,72], [0,706], [18,38],
    [3], [PINK REGENCY TEACUP AND SAUCER, ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [2,72], [0,905], [17,79],
    [4], [PINK REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [3,17], [0,826], [16,25],
    [5], [GREEN REGENCY TEACUP AND SAUCER -> PINK REGENCY TEACUP AND SAUCER], [3,17], [0,624], [16,25],
    [6], [GREEN REGENCY TEACUP AND SAUCER, PINK REGENCY TEACUP AND SAUCER -> ROSES REGENCY TEACUP AND SAUCER], [2,72], [0,856], [16,03],
    [7], [GARDENERS KNEELING PAD CUP OF TEA -> GARDENERS KNEELING PAD KEEP CALM], [2,74], [0,720], [15,74],
    [8], [REGENCY CAKESTAND 3 TIER, ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [2,04], [0,777], [15,28],
    [9], [GREEN REGENCY TEACUP AND SAUCER, REGENCY CAKESTAND 3 TIER -> ROSES REGENCY TEACUP AND SAUCER], [2,04], [0,802], [15,00],
    [10], [PINK REGENCY TEACUP AND SAUCER -> ROSES REGENCY TEACUP AND SAUCER], [3,00], [0,782], [14,64],
    [11], [GREEN REGENCY TEACUP AND SAUCER -> ROSES REGENCY TEACUP AND SAUCER], [3,85], [0,757], [14,16],
    [12], [ROSES REGENCY TEACUP AND SAUCER -> GREEN REGENCY TEACUP AND SAUCER], [3,85], [0,720], [14,16],
    [13], [DOLLY GIRL LUNCH BOX -> SPACEBOY LUNCH BOX], [2,70], [0,633], [14,03],
    [14], [JUMBO BAG PEARS -> JUMBO BAG APPLES], [2,03], [0,682], [13,92],
    [15], [CHARLOTTE BAG PINK POLKADOT -> RED RETROSPOT CHARLOTTE BAG], [2,62], [0,703], [13,56],
    [16], [STRAWBERRY CHARLOTTE BAG -> RED RETROSPOT CHARLOTTE BAG], [2,44], [0,673], [12,99],
    [17], [ALARM CLOCK BAKELIKE RED -> ALARM CLOCK BAKELIKE GREEN], [3,21], [0,609], [12,40],
    [18], [ALARM CLOCK BAKELIKE GREEN -> ALARM CLOCK BAKELIKE RED], [3,21], [0,653], [12,40],
    [19], [WOODLAND CHARLOTTE BAG -> RED RETROSPOT CHARLOTTE BAG], [2,54], [0,606], [11,69],
    [20], [PAPER CHAIN KIT VINTAGE CHRISTMAS -> PAPER CHAIN KIT 50'S CHRISTMAS], [2,77], [0,673], [11,58],
    [21], [ALARM CLOCK BAKELIKE PINK -> ALARM CLOCK BAKELIKE RED], [2,36], [0,600], [11,40],
    [22], [JUMBO BAG PINK POLKADOT, JUMBO STORAGE BAG SUKI -> JUMBO BAG RED RETROSPOT], [2,07], [0,802], [7,65],
    [23], [JUMBO BAG PINK POLKADOT -> JUMBO BAG RED RETROSPOT], [4,13], [0,677], [6,46],
    [24], [JUMBO BAG SCANDINAVIAN BLUE PAISLEY -> JUMBO BAG RED RETROSPOT], [2,25], [0,677], [6,45],
    [25], [JUMBO BAG STRAWBERRY -> JUMBO BAG RED RETROSPOT], [2,69], [0,651], [6,21],
    [26], [JUMBO  BAG BAROQUE BLACK WHITE -> JUMBO BAG RED RETROSPOT], [2,93], [0,627], [5,98],
    [27], [JUMBO BAG SPACEBOY DESIGN -> JUMBO BAG RED RETROSPOT], [2,15], [0,625], [5,96],
    [28], [JUMBO BAG WOODLAND ANIMALS -> JUMBO BAG RED RETROSPOT], [2,68], [0,620], [5,91],
    [29], [RED HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [2,48], [0,668], [5,90],
    [30], [JUMBO STORAGE BAG SUKI -> JUMBO BAG RED RETROSPOT], [3,63], [0,611], [5,83],
    )
  ],
  caption: [Seluruh 30 aturan asosiasi pada support 2\% dan confidence 0,6]
)
