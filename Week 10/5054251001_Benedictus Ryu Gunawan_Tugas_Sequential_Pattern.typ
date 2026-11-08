// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Laporan Sequential Pattern Analysis pada Dataset Online Retail",
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
  #set par(justify: false)
  #v(2em)
  #text(size: 18pt, weight: "bold")[TUGAS - WEEK 10]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN SEQUENTIAL PATTERN ANALYSIS PADA DATASET ONLINE RETAIL]
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

Sequential pattern mining adalah teknik untuk menemukan pola kemunculan item yang berurutan dalam suatu sequence. Berbeda dari association rule mining yang memperlakukan transaksi sebagai keranjang tanpa urutan, sequential pattern mining memperhitungkan waktu: pola A -> B berarti B muncul pada transaksi yang lebih baru daripada A. Pada data ritel, pola semacam ini dapat menunjukkan produk yang biasa dibeli ulang, urutan pembelian beberapa varian desain, atau langkah yang mendahului pembelian produk tertentu.

Dataset Online Retail dari UCI Machine Learning Repository berisi 541.909 baris transaksi pengecer UK pada Desember 2010 sampai Desember 2011. Data mentah memuat invoice yang dibatalkan, quantity negatif atau nol, Description kosong, CustomerID kosong, dan baris non-produk. Karena sequence dibentuk per pelanggan, pembersihan dan identifikasi pelanggan menjadi tahap penting sebelum algoritma diterapkan. Laporan ini memakai PrefixSpan karena algoritma tersebut menumbuhkan pola melalui proyeksi database sequence dan tidak membangkitkan kandidat secara eksplisit seperti GSP atau Apriori.

== Tujuan

Tujuan praktikum ini adalah:

1. Mengimpor dan memahami struktur dataset Online Retail.
2. Membersihkan data serta menampilkan jumlah baris, invoice, dan pelanggan sebelum dan sesudah pembersihan.
3. Membentuk sequence pembelian per pelanggan dari itemset invoice yang diurutkan berdasarkan waktu.
4. Menerapkan PrefixSpan dengan minimum support awal 0,01 dan menjelaskan penyesuaian parameternya.
5. Mengevaluasi pola dengan support dan confidence, lalu menginterpretasikan tiga pola terbaik untuk kebutuhan bisnis ritel.

Alur kerja mengikuti notebook `5054251001_Benedictus Ryu Gunawan_Tugas_Sequential_Pattern.ipynb`. Seluruh gambar dan tabel pada laporan ini dihasilkan oleh notebook tersebut dan tersimpan pada folder `output/`.

= Deskripsi Dataset

Dataset `Online Retail.xlsx` terdiri dari 541.909 baris dan 8 kolom. Satu baris merepresentasikan satu baris item pada invoice, bukan satu transaksi unik. Jumlah invoice adalah 25.900, jumlah pelanggan dengan CustomerID adalah 4.372, dan jumlah Description unik adalah 4.223 sebelum pembersihan. Periode transaksi berlangsung dari 1 Desember 2010 sampai 9 Desember 2011, dan 91,43\% baris berasal dari United Kingdom.

#figure(
  table(
    columns: (2fr, 3fr),
    stroke: 0.5pt,
    table.header([*Atribut*], [*Nilai*]),
    [Jumlah baris], [541.909],
    [Jumlah kolom], [8],
    [Jumlah invoice], [25.900],
    [Jumlah pelanggan], [4.372],
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

CustomerID menjadi kunci utama karena sequence dibentuk per pelanggan. Sebanyak 135.080 baris (24,93\%) tidak memiliki CustomerID sehingga tidak dapat dimasukkan ke sequence mana pun. Description kosong harus dihapus karena item tidak dapat diidentifikasi. Missing values pada kolom lain tidak ditemukan.

#figure(
  image("output/missing_values.png", width: 82%),
  caption: [Jumlah nilai kosong per kolom pada data mentah. CustomerID mendominasi dengan 135.080 nilai kosong; Description hanya 1.454 nilai kosong.],
) <fig-missing>

= Eksplorasi dan Pembersihan Data

== Kolom yang Relevan

Kolom yang dipakai untuk sequential pattern mining adalah `CustomerID` sebagai identitas pelanggan, `InvoiceDate` dan `InvoiceNo` untuk urutan waktu, `Description` sebagai nama item, dan `Quantity` untuk memastikan baris adalah pembelian. `StockCode` dipakai untuk menyaring baris non-produk. `UnitPrice` dan `Country` hanya dipakai sebagai konteks, bukan untuk pembentukan sequence.

== Tahapan Pembersihan

Pembersihan dilakukan secara berurutan:

+ Menyeragamkan `Description` menjadi huruf kapital dan menghapus spasi berlebih di awal, akhir, dan tengah teks, serta merapikan `InvoiceNo` dan `StockCode`.
+ Menghapus baris dengan `Description` kosong karena item tidak dapat diidentifikasi.
+ Menghapus invoice yang dibatalkan, yaitu `InvoiceNo` yang diawali huruf C.
+ Menghapus baris dengan `Quantity` negatif atau nol.
+ Menghapus baris dengan `CustomerID` kosong karena sequence disusun per pelanggan.
+ Menghapus baris non-produk seperti postage, bank charges, manual, dan gift voucher agar pola tidak berisi biaya layanan.

Langkah terakhir adalah tambahan agar pola yang ditemukan benar-benar mencerminkan produk ritel. Setiap tahap dicatat jumlah baris, invoice, dan pelanggannya.

#figure(
  text(size: 8pt)[
    #table(
      columns: (2.1fr, 0.8fr, 0.8fr, 0.8fr, 0.9fr, 0.8fr, 0.9fr),
      align: (left, right, right, right, right, right, right),
      stroke: 0.5pt,
      table.header([*Tahap*], [*Baris*], [*Invoice*], [*Pelanggan*], [*Baris dihapus*], [*Invoice hilang*], [*Pelanggan hilang*]),
      [Data mentah], [541.909], [25.900], [4.372], [0], [0], [0],
      [Hapus Description kosong], [540.455], [24.446], [4.372], [1.454], [1.454], [0],
      [Hapus invoice batal (C)], [531.167], [20.610], [4.339], [9.288], [3.836], [33],
      [Hapus Quantity <= 0], [530.693], [20.136], [4.339], [474], [474], [0],
      [Hapus CustomerID kosong], [397.924], [18.536], [4.339], [132.769], [1.600], [0],
      [Hapus baris non-produk], [396.370], [18.405], [4.335], [1.554], [131], [4],
    )
  ],
  caption: [Jumlah baris, invoice, dan pelanggan sebelum dan sesudah setiap tahap pembersihan]
)

#figure(
  image("output/cleaning_funnel.png", width: 100%),
  caption: [Dampak pembersihan per tahap. Penghapusan CustomerID kosong menghapus baris terbanyak, sedangkan pembatalan invoice menghapus invoice terbanyak.],
) <fig-cleaning>

Pembersihan menurunkan dataset dari 541.909 baris, 25.900 invoice, dan 4.372 pelanggan menjadi 396.370 baris, 18.405 invoice, dan 4.335 pelanggan. Tahap yang menghapus baris terbanyak adalah penghapusan CustomerID kosong (132.769 baris), sedangkan tahap yang menghapus invoice terbanyak adalah pembatalan invoice (3.836 invoice). Sebanyak 33 pelanggan hanya memiliki invoice yang dibatalkan dan 4 pelanggan hanya membeli layanan non-produk sehingga tidak memiliki sequence valid.

Jumlah Description unik turun dari 4.223 menjadi 3.852 setelah penyeragaman teks dan penghapusan baris non-produk. Penurunan ini sebagian berasal dari penggabungan nama produk yang sebelumnya berbeda hanya karena spasi ganda, misalnya `LUNCH BAG  BLACK SKULL.` dan `LUNCH BAG BLACK SKULL.`.

== Distribusi Ukuran Keranjang

Ukuran keranjang dihitung dari jumlah Description unik per invoice. Distribusinya miring ke kanan: median 15 produk, rata-rata 20,98 produk, kuartil ketiga 27 produk, dan nilai maksimum 540 produk. Sebanyak 90\% invoice berisi paling banyak 46 produk, 95\% paling banyak 62 produk, dan 99\% paling banyak 103,96 produk. Invoice besar tetap dipertahankan karena merepresentasikan pembelian grosir atau pesanan besar yang sah.

#figure(
  image("output/invoice_size_distribution.png", width: 100%),
  caption: [Distribusi jumlah produk unik per invoice dan ECDF ukuran keranjang. Median 15 produk; 90\% invoice berisi paling banyak 46 produk.],
) <fig-invoice-size>

== Produk Terpopuler

Produk dengan pelanggan terbanyak adalah REGENCY CAKESTAND 3 TIER (881 pelanggan, 20,32\%), WHITE HANGING HEART T-LIGHT HOLDER (856 pelanggan, 19,75\%), dan PARTY BUNTING (708 pelanggan, 16,33\%). Sepuluh produk teratas hanya mencakup 2,55\% dari seluruh pasangan pelanggan-produk, dan dibutuhkan 1.338 produk untuk mencakup 80\% pasangan. Distribusi long tail ini membuat pencarian pola pada seluruh katalog menjadi sangat mahal, sehingga kosakata produk perlu dibatasi secara terkontrol.

#figure(
  table(
    columns: (3fr, 1fr, 1fr),
    align: (left, right, right),
    stroke: 0.5pt,
    table.header([*Produk*], [*Pelanggan*], [*Support (\%)*]),
    [REGENCY CAKESTAND 3 TIER], [881], [20,32\%],
    [WHITE HANGING HEART T-LIGHT HOLDER], [856], [19,75\%],
    [PARTY BUNTING], [708], [16,33\%],
    [ASSORTED COLOUR BIRD ORNAMENT], [678], [15,64\%],
    [SET OF 3 CAKE TINS PANTRY DESIGN], [640], [14,76\%],
    [JUMBO BAG RED RETROSPOT], [635], [14,65\%],
    [PACK OF 72 RETROSPOT CAKE CASES], [635], [14,65\%],
    [PAPER CHAIN KIT 50'S CHRISTMAS], [613], [14,14\%],
    [NATURAL SLATE HEART CHALKBOARD], [587], [13,54\%],
    [BAKING SET 9 PIECE RETROSPOT], [581], [13,40\%],
  ),
  caption: [Sepuluh produk dengan jumlah pelanggan terbanyak]
)

#figure(
  image("output/top_products.png", width: 100%),
  caption: [Produk terpopuler dan kurva kumulatif pasangan pelanggan-produk. Distribusi produk sangat panjang; 1.338 produk diperlukan untuk mencapai 80\% pasangan.],
) <fig-top-products>

== Panjang Sequence per Pelanggan

Sequence per pelanggan berisi daftar invoice yang diurutkan berdasarkan waktu. Sebanyak 1.506 pelanggan (34,74\%) hanya memiliki satu invoice dan 2.337 pelanggan (53,91\%) memiliki paling banyak dua invoice. Rata-rata jumlah invoice per pelanggan adalah 4,25 dengan median 2 dan nilai maksimum 206 invoice. Rata-rata satu pelanggan memiliki 89,08 item unik, dengan median 40 item dan maksimum 7.466 item. Sebagian besar pelanggan adalah pembeli musiman, tetapi ada kelompok kecil pelanggan setia dengan ratusan transaksi.


#figure(
  image("output/sequence_length_distribution.png", width: 100%),
  caption: [Distribusi jumlah invoice per pelanggan dan ECDF. Median 2 invoice; 34,74\% pelanggan hanya memiliki satu invoice.],
) <fig-sequence-length>

= Persiapan Data untuk Sequential Pattern Mining

Data baris demi baris diubah menjadi sequence pembelian per pelanggan. Untuk setiap pasangan `CustomerID` dan `InvoiceNo`, daftar Description diubah menjadi himpunan unik agar produk yang sama tidak dihitung dua kali dalam satu invoice. Setiap itemset diurutkan secara kanonik, dan itemset antar invoice diurutkan berdasarkan `InvoiceDate` lalu `InvoiceNo`. Hasilnya adalah satu sequence per pelanggan yang berbentuk daftar itemset.

Contoh sequence tiga pelanggan ditampilkan pada tabel berikut. Seluruh sequence disimpan pada file `output/customer_sequences.csv`.

#figure(
  text(size: 8pt)[
    #table(
      columns: (1.05fr, 0.65fr, 2.65fr, 2.65fr),
      align: (center, right, left, left),
      stroke: 0.5pt,
      table.header([*CustomerID*], [*Invoice*], [*Itemset pertama*], [*Itemset kedua*]),
      [12494], [7], [RECIPE BOX RETROSPOT; RED RETROSPOT CAKE STAND], [LUNCH BAG DOLLY GIRL DESIGN],
      [12643], [6], [MINI WOODEN HAPPY BIRTHDAY GARLAND], [SMALL RED RETROSPOT WINDMILL; SMALL SKULL WINDMILL; WOODEN HAPPY BIRTHDAY GARLAND],
      [12664], [9], [BLUE 3 PIECE POLKADOT CUTLERY SET; GREEN 3 PIECE POLKADOT CUTLERY SET; PINK 3 PIECE POLKADOT CUTLERY SET; RED 3 PIECE RETROSPOT CUTLERY SET], [CHILDRENS CUTLERY POLKADOT BLUE; CHILDRENS CUTLERY POLKADOT GREEN; CHILDRENS CUTLERY POLKADOT PINK],
    )
  ],
  caption: [Contoh sequence pelanggan setelah pembersihan. Setiap itemset adalah produk unik pada satu invoice; itemset diurutkan berdasarkan waktu.]
)

= Penerapan Algoritma PrefixSpan

== Pemilihan PrefixSpan

PrefixSpan membangun pola dengan memproyeksikan database sequence pada setiap prefix yang frequent. Berbeda dari GSP atau Apriori yang membangkitkan kandidat, PrefixSpan hanya menumbuhkan prefix yang benar-benar didukung data sehingga lebih efisien pada sequence yang panjang. Implementasi memakai pustaka `prefixspan` dengan `maxlen=3`, sehingga pola yang dicari terdiri dari satu sampai tiga langkah.

Setiap invoice adalah itemset, tetapi PrefixSpan bekerja pada urutan item. Karena itu itemset diekspansi menjadi daftar item unik dengan urutan kanonik, lalu seluruh item pelanggan digabung secara kronologis. Support setiap pola yang ditemukan PrefixSpan diverifikasi ulang pada level itemset dengan aturan ketat: item pertama harus muncul pada invoice yang lebih awal daripada item berikutnya. Verifikasi ini membuang pola yang hanya muncul karena dua produk kebetulan berada pada invoice yang sama, sehingga pola yang dilaporkan benar-benar berurutan antar waktu.

== Parameter Awal dan Penyesuaian

Titik awal tugas adalah minimum support 0,01 atau 1\% dari jumlah pelanggan, yaitu 43 pelanggan. Pada nilai ini terdapat 1.783 produk yang lolos filter. Pencarian pada seluruh kosakata tersebut tidak diselesaikan karena melebihi batas waktu 60 menit, sehingga support dinaikkan bertahap dan diuji pada nilai 2\% sampai 5\%. Tabel dan grafik berikut menunjukkan jumlah pola yang bertahan setelah verifikasi itemset.

#figure(
  table(
    columns: (0.8fr, 1fr, 1fr, 1fr, 1.2fr, 1fr),
    align: (center, right, right, right, right, right),
    stroke: 0.5pt,
    table.header([*Support*], [*Pelanggan*], [*Produk*], [*Pola total*], [*Pola berurutan*], [*Waktu (detik)*]),
    [1\%], [43], [1.783], [tidak selesai], [tidak selesai], [> 3.600],
    [2\%], [86], [1.054], [3.118], [2.064], [22,24],
    [3\%], [130], [662], [964], [302], [7,12],
    [4\%], [173], [421], [485], [64], [3,12],
    [5\%], [216], [266], [276], [10], [1,47],
  ),
  caption: [Sensitivitas minimum support. Waktu diukur pada lingkungan notebook dan dapat berbeda sedikit antar eksekusi.]
)

#figure(
  image("output/parameter_sensitivity.png", width: 100%),
  caption: [Kurva sensitivitas parameter. Garis putus-putus menandai support final 3\%; jumlah pola berurutan turun tajam dari 2.064 menjadi 10.],
) <fig-sensitivity>

Support 2\% masih menghasilkan 2.064 pola berurutan, terlalu banyak untuk ditinjau dan diinterpretasikan. Support 4\% hanya menyisakan 64 pola berurutan, sedangkan support 5\% hanya menyisakan 10 pola sehingga banyak pola penting hilang. Support 3\% dipilih karena menghasilkan 302 pola berurutan yang masih cukup kaya untuk dianalisis, dengan 662 produk sebagai kosakata.

== Model Final

Kombinasi final adalah minimum support 3\% (130 pelanggan), kosakata 662 produk, dan panjang pola maksimum tiga langkah. Hasilnya adalah 964 pola, terdiri dari 662 pola satu langkah (produk frequent), 291 pola dua langkah, dan 11 pola tiga langkah. Pola satu langkah dipakai sebagai konteks produk populer; analisis pola berurutan difokuskan pada 302 pola dengan panjang minimal dua.

Dari 302 pola berurutan, 231 pola adalah lintas produk dan 71 pola adalah pembelian ulang. Pola pembelian ulang terdiri dari 60 pola dua langkah dan 11 pola tiga langkah. Seluruh 964 pola tersimpan pada `output/patterns_final.csv`, sedangkan 20 pola berurutan teratas tersimpan pada `output/top_patterns.csv`.

#figure(
  image("output/pattern_length_distribution.png", width: 62%),
  caption: [Distribusi panjang pola pada support 3\%. Sebagian besar pola berukuran satu langkah; hanya 11 pola berukuran tiga langkah.],
) <fig-pattern-length>

Confidence dihitung sebagai support pola dibagi support prefix-nya. Untuk pola dua langkah A -> B, confidence adalah peluang pelanggan membeli B pada invoice berikutnya jika sebelumnya membeli A. Untuk pola tiga langkah A -> B -> C, confidence adalah peluang melanjutkan ke C jika sudah membeli A lalu B. Nilai ini berbeda dari confidence association rule karena arah waktunya diperhitungkan.

= Evaluasi Pola Berurutan

== Ukuran Evaluasi

#figure(
  table(
    columns: (1fr, 2.6fr, 3fr),
    stroke: 0.5pt,
    table.header([*Metrik*], [*Rumus*], [*Interpretasi*]),
    [Support], [jumlah pelanggan dengan pola / 4.335], [Proporsi pelanggan yang memiliki pola tersebut],
    [Confidence], [support(pola) / support(prefix)], [Peluang melanjutkan prefix ke langkah berikutnya],
    [Support prefix], [jumlah pelanggan dengan prefix], [Penyebut confidence, bukan jumlah invoice],
    [Urutan ketat], [invoice item pertama < invoice item berikutnya], [Item pada pola harus muncul pada invoice yang lebih baru],
  ),
  caption: [Ukuran evaluasi pola berurutan]
)

== Pola Berurutan dengan Support Tertinggi

Tabel berikut menampilkan sepuluh pola berurutan dengan support tertinggi. Pola dengan item berulang, misalnya A -> A, termasuk kategori pembelian ulang dan muncul paling sering karena produk populer cenderung dibeli lagi pada invoice berikutnya. Pola lintas produk, yaitu A -> B dengan A dan B berbeda, lebih relevan untuk rekomendasi cross-sell.

#figure(
  text(size: 7.2pt)[
    #table(
      columns: (0.35fr, 4.0fr, 0.85fr, 0.72fr, 0.72fr, 0.9fr),
      align: (center, left, left, right, right, right),
      stroke: 0.5pt,
      inset: 3pt,
      table.header([*No*], [*Pola*], [*Tipe*], [*Pelanggan*], [*Support*], [*Confidence*]),
      [1], [WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [Pembelian ulang], [405], [9,34\%], [0,473],
      [2], [REGENCY CAKESTAND 3 TIER -> REGENCY CAKESTAND 3 TIER], [Pembelian ulang], [330], [7,61\%], [0,375],
      [3], [JUMBO BAG RED RETROSPOT -> JUMBO BAG RED RETROSPOT], [Pembelian ulang], [312], [7,20\%], [0,491],
      [4], [ASSORTED COLOUR BIRD ORNAMENT -> ASSORTED COLOUR BIRD ORNAMENT], [Pembelian ulang], [291], [6,71\%], [0,429],
      [5], [PARTY BUNTING -> PARTY BUNTING], [Pembelian ulang], [280], [6,46\%], [0,395],
      [6], [LUNCH BAG RED RETROSPOT -> LUNCH BAG RED RETROSPOT], [Pembelian ulang], [276], [6,37\%], [0,519],
      [7], [LUNCH BAG BLACK SKULL. -> LUNCH BAG BLACK SKULL.], [Pembelian ulang], [229], [5,28\%], [0,500],
      [8], [LUNCH BAG SUKI DESIGN -> LUNCH BAG SUKI DESIGN], [Pembelian ulang], [226], [5,21\%], [0,521],
      [9], [SET OF 3 CAKE TINS PANTRY DESIGN -> SET OF 3 CAKE TINS PANTRY DESIGN], [Pembelian ulang], [225], [5,19\%], [0,352],
      [10], [WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [Pembelian ulang], [222], [5,12\%], [0,548],
    )
  ],
  caption: [Sepuluh pola berurutan dengan support tertinggi pada support 3\%. Kolom Pelanggan adalah jumlah pelanggan; kolom Support adalah persentase dari 4.335 pelanggan.]
)

#figure(
  image("output/support_confidence_scatter.png", width: 82%),
  caption: [Sebaran support dan confidence untuk 302 pola berurutan. Warna biru menandai pola lintas produk dan warna merah menandai pembelian ulang.],
) <fig-scatter>

== Tiga Pola Terbaik Berdasarkan Support

Jika seluruh pola berurutan diurutkan berdasarkan support, tiga pola teratas adalah pembelian ulang produk populer. Ketiganya adalah:

#figure(
  text(size: 8pt)[
    #table(
      columns: (0.35fr, 4.6fr, 0.75fr, 0.75fr, 0.9fr),
      align: (center, left, right, right, right),
      stroke: 0.5pt,
      table.header([*No*], [*Pola*], [*Pelanggan*], [*Support*], [*Confidence*]),
      [1], [WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [405], [9,34\%], [0,473],
      [2], [REGENCY CAKESTAND 3 TIER -> REGENCY CAKESTAND 3 TIER], [330], [7,61\%], [0,375],
      [3], [JUMBO BAG RED RETROSPOT -> JUMBO BAG RED RETROSPOT], [312], [7,20\%], [0,491],
    )
  ],
  caption: [Tiga pola berurutan teratas berdasarkan support]
)

Pola-pola tersebut menunjukkan pelanggan yang membeli produk dekorasi populer cenderung membelinya lagi pada invoice berikutnya. Confidence 0,473 berarti 47,3\% dari 856 pelanggan yang pernah membeli WHITE HANGING HEART T-LIGHT HOLDER membelinya lagi pada invoice lain dalam periode data. Untuk REGENCY CAKESTAND 3 TIER, 330 dari 881 pelanggan (37,5\%) melakukan pembelian ulang. Untuk JUMBO BAG RED RETROSPOT, 312 dari 635 pelanggan (49,1\%) melakukan pembelian ulang.

Karena tiga pola teratas didominasi pembelian ulang, tabel berikut menyajikan tiga pola lintas produk teratas untuk kebutuhan cross-sell. Pola ini lebih informatif untuk rekomendasi produk yang berbeda.

#figure(
  text(size: 8pt)[
    #table(
      columns: (0.35fr, 4.6fr, 0.75fr, 0.75fr, 0.9fr),
      align: (center, left, right, right, right),
      stroke: 0.5pt,
      table.header([*No*], [*Pola*], [*Pelanggan*], [*Support*], [*Confidence*]),
      [1], [LUNCH BAG RED RETROSPOT -> LUNCH BAG BLACK SKULL.], [212], [4,89\%], [0,398],
      [2], [LUNCH BAG CARS BLUE -> LUNCH BAG RED RETROSPOT], [209], [4,82\%], [0,436],
      [3], [LUNCH BAG BLACK SKULL. -> LUNCH BAG RED RETROSPOT], [208], [4,80\%], [0,454],
    )
  ],
  caption: [Tiga pola lintas produk teratas berdasarkan support]
)

#figure(
  image("output/top_patterns_support.png", width: 100%),
  caption: [Dua belas pola lintas produk dengan support tertinggi. Kelompok lunch bag mendominasi daftar, diikuti pola perlengkapan kue dan jumbo bag.],
) <fig-top-patterns>

Interpretasi ketiga pola tersebut adalah sebagai berikut.

+ *Pola lunch bag varian merah ke hitam.* Sebanyak 39,8\% dari 532 pelanggan yang membeli LUNCH BAG RED RETROSPOT membeli LUNCH BAG BLACK SKULL. pada invoice berikutnya. Support 4,89\% berarti pola ini muncul pada 212 dari 4.335 pelanggan.
+ *Pola lunch bag varian mobil ke merah.* Sebanyak 43,6\% dari 479 pelanggan yang membeli LUNCH BAG CARS BLUE melanjutkan dengan LUNCH BAG RED RETROSPOT. Pola ini menunjukkan pembelian beberapa desain lunch bag, bukan pembelian ulang produk yang sama.
+ *Pola lunch bag hitam ke merah.* Sebanyak 45,4\% dari 458 pelanggan yang membeli LUNCH BAG BLACK SKULL. kemudian membeli LUNCH BAG RED RETROSPOT. Arah ini hampir simetris dengan pola pertama, sehingga kedua varian saling melengkapi.

Pola lain yang menonjol adalah REGENCY CAKESTAND 3 TIER -> SET OF 3 REGENCY CAKE TINS (support 206, confidence 0,234) dan JUMBO BAG RED RETROSPOT -> JUMBO BAG VINTAGE DOILY (support 201, confidence 0,317). Keduanya menunjukkan pembelian varian dari keluarga produk yang sama, bukan cross-sell antar kategori yang berbeda.

== Implikasi Bisnis

Pola pembelian ulang dapat dipakai untuk program loyalitas, pengingat restock, dan penawaran paket isi ulang. Produk seperti lilin dekorasi, cake stand, dan jumbo bag memiliki peluang pembelian ulang yang cukup tinggi, sehingga pelanggan yang sudah membeli satu unit dapat ditawari diskon untuk pembelian kedua atau paket beberapa unit.

Pola lintas produk menunjukkan pelanggan cenderung mengoleksi beberapa desain dari keluarga produk yang sama. Lunch bag adalah contoh terkuat: pembeli satu desain memiliki peluang 39,8\% sampai 45,4\% membeli desain lain pada transaksi berikutnya. Rekomendasi yang dapat diterapkan adalah menampilkan seluruh varian dalam satu halaman produk, membuat bundling dua atau tiga desain, dan mengirim pengingat koleksi kepada pelanggan yang baru membeli satu desain. Pola serupa muncul pada jumbo bag dan set kue Regency.

Namun, support pola hanya 3\% sampai 9\% dari seluruh pelanggan. Pola ini sebaiknya diprioritaskan untuk pelanggan yang sudah memiliki item pertama, bukan untuk seluruh basis pelanggan. Dataset juga berasal dari satu pengecer UK pada 2010 sampai 2011, tidak memuat margin atau stok, dan 24,93\% baris tanpa CustomerID tidak dapat dianalisis. Hubungan yang ditemukan adalah korelasi waktu, bukan bukti kausal, sehingga validasi dengan eksperimen A/B tetap diperlukan.

= Kesimpulan

Dataset Online Retail berhasil dibersihkan dari 541.909 baris, 25.900 invoice, dan 4.372 pelanggan menjadi 396.370 baris, 18.405 invoice, dan 4.335 pelanggan. Sequence pembelian per pelanggan dibentuk dari 18.405 itemset invoice yang diurutkan berdasarkan waktu. PrefixSpan dengan minimum support 3\% (130 pelanggan), kosakata 662 produk, dan panjang maksimum tiga langkah menghasilkan 964 pola, terdiri dari 662 pola satu langkah, 291 pola dua langkah, dan 11 pola tiga langkah.

Pola berurutan terkuat adalah pembelian ulang produk dekorasi populer: WHITE HANGING HEART T-LIGHT HOLDER (support 9,34\%, confidence 0,473), REGENCY CAKESTAND 3 TIER (support 7,61\%, confidence 0,375), dan JUMBO BAG RED RETROSPOT (support 7,20\%, confidence 0,491). Pola lintas produk terkuat adalah kelompok lunch bag: LUNCH BAG RED RETROSPOT -> LUNCH BAG BLACK SKULL. (support 4,89\%, confidence 0,398), LUNCH BAG CARS BLUE -> LUNCH BAG RED RETROSPOT (support 4,82\%, confidence 0,436), dan LUNCH BAG BLACK SKULL. -> LUNCH BAG RED RETROSPOT (support 4,80\%, confidence 0,454).

Secara keseluruhan, pelanggan Online Retail cenderung membeli ulang produk yang sama dan melanjutkan dengan varian desain dari keluarga produk yang sama. Peluang terbesar untuk rekomendasi terletak pada bundling varian lunch bag, jumbo bag, dan peralatan kue, bukan pada cross-sell antar kategori yang jauh berbeda.

== Saran Pengembangan

+ Menguji pola dengan minimum support lebih rendah setelah menggabungkan produk long tail ke dalam kategori, agar pola antar kategori tetap dapat ditemukan tanpa ledakan kombinasi.
+ Menambahkan batas waktu antar invoice, misalnya maksimum 90 hari, agar pola yang ditemukan lebih relevan untuk rekomendasi musiman.
+ Membandingkan PrefixSpan dengan GSP atau SPADE, serta menambahkan metrik lift dan conviction untuk mengukur kekuatan asosiasi berurutan.
+ Memisahkan pelanggan ritel dan grosir karena pola pembelian ulang pada pelanggan grosir dapat mendominasi hasil.
+ Memvalidasi rekomendasi dengan eksperimen A/B sebelum diterapkan pada sistem produksi.

= Lampiran: 20 Pola Berurutan dengan Support Tertinggi

#figure(
  text(size: 7pt)[
    #table(
      columns: (0.35fr, 4.9fr, 0.75fr, 0.7fr, 0.85fr),
      align: (center, left, right, right, right),
      inset: 2.5pt,
      stroke: 0.5pt,
      table.header([*No*], [*Pola*], [*Pelanggan*], [*Support*], [*Confidence*]),
      [1], [WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [405], [9,34\%], [0,473],
      [2], [REGENCY CAKESTAND 3 TIER -> REGENCY CAKESTAND 3 TIER], [330], [7,61\%], [0,375],
      [3], [JUMBO BAG RED RETROSPOT -> JUMBO BAG RED RETROSPOT], [312], [7,20\%], [0,491],
      [4], [ASSORTED COLOUR BIRD ORNAMENT -> ASSORTED COLOUR BIRD ORNAMENT], [291], [6,71\%], [0,429],
      [5], [PARTY BUNTING -> PARTY BUNTING], [280], [6,46\%], [0,395],
      [6], [LUNCH BAG RED RETROSPOT -> LUNCH BAG RED RETROSPOT], [276], [6,37\%], [0,519],
      [7], [LUNCH BAG BLACK SKULL. -> LUNCH BAG BLACK SKULL.], [229], [5,28\%], [0,500],
      [8], [LUNCH BAG SUKI DESIGN -> LUNCH BAG SUKI DESIGN], [226], [5,21\%], [0,521],
      [9], [SET OF 3 CAKE TINS PANTRY DESIGN -> SET OF 3 CAKE TINS PANTRY DESIGN], [225], [5,19\%], [0,352],
      [10], [WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER -> WHITE HANGING HEART T-LIGHT HOLDER], [222], [5,12\%], [0,548],
      [11], [LUNCH BAG RED RETROSPOT -> LUNCH BAG BLACK SKULL.], [212], [4,89\%], [0,398],
      [12], [LUNCH BAG CARS BLUE -> LUNCH BAG RED RETROSPOT], [209], [4,82\%], [0,436],
      [13], [LUNCH BAG BLACK SKULL. -> LUNCH BAG RED RETROSPOT], [208], [4,80\%], [0,454],
      [14], [LUNCH BAG RED RETROSPOT -> LUNCH BAG SPACEBOY DESIGN], [207], [4,78\%], [0,389],
      [15], [SPOTTY BUNTING -> SPOTTY BUNTING], [207], [4,78\%], [0,363],
      [16], [LUNCH BAG RED RETROSPOT -> LUNCH BAG SUKI DESIGN], [206], [4,75\%], [0,387],
      [17], [REGENCY CAKESTAND 3 TIER -> SET OF 3 REGENCY CAKE TINS], [206], [4,75\%], [0,234],
      [18], [LUNCH BAG CARS BLUE -> LUNCH BAG CARS BLUE], [205], [4,73\%], [0,428],
      [19], [LUNCH BAG PINK POLKADOT -> LUNCH BAG RED RETROSPOT], [201], [4,64\%], [0,453],
      [20], [HEART OF WICKER SMALL -> HEART OF WICKER SMALL], [201], [4,64\%], [0,351],
    )
  ],
  caption: [20 pola berurutan dengan support tertinggi. Seluruh 964 pola tersedia pada file `output/patterns_final.csv`.]
)
