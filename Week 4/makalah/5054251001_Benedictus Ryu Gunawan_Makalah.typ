// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Contoh Penerapan Data Science pada BPJS Kesehatan",
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
  #text(size: 18pt, weight: "bold")[TUGAS MAKALAH WEEK 4]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN HASIL EXPLORATORY DATA ANALYSIS (EDA) & PREPROCESSING KARTU YU-GI--OH!]
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

Yu-Gi-Oh! adalah sebuah permainan kartu koleksi (Trading Card Game atau TCG) yang diciptakan oleh Kazuki Takahashi dan pertama kali diperkenalkan melalui serial manga *Yu-Gi-Oh!* pada tahun 1996. Seiring perkembangan waktu, permainan ini berkembang menjadi salah satu permainan kartu paling populer di dunia dengan ribuan jenis kartu yang memiliki efek, atribut, tipe, dan mekanisme permainan yang beragam.

Setiap kartu dalam permainan Yu-Gi-Oh! memiliki karakteristik unik seperti jenis kartu (*Monster*, *Spell*, atau *Trap*), nilai serangan (*Attack/ATK*), nilai pertahanan (*Defense/DEF*), atribut, ras, archetype, hingga efek khusus yang mempengaruhi jalannya permainan. Kompleksitas tersebut menghasilkan sejumlah besar data yang menarik untuk dianalisis menggunakan teknik data mining dan eksplorasi data.

Data yang digunakan pada laporan ini berasal dari YGOPRODeck yang diambil pada 11 September 2026. Data tersebut tidak hanya mencakup karakteristik permainan dari setiap kartu, tetapi juga informasi tambahan seperti harga pasar, status legalitas pada berbagai format permainan, serta deskripsi efek kartu. Keberadaan data yang kaya akan informasi tersebut membuka peluang untuk melakukan analisis eksploratif guna memahami pola, hubungan antar fitur, dan karakteristik umum yang terdapat pada kartu-kartu Yu-Gi-Oh!.



== Tujuan

Tujuan dari analisis ini adalah:

1. Memahami struktur dan kualitas dataset.
2. Mengidentifikasi pola nilai hilang (missing values).
3. Menganalisis distribusi variabel numerik.
4. Mengevaluasi hubungan antar fitur.
5. Mengidentifikasi outlier pada dataset.
6. Menganalisis karakteristik variabel kategorikal.
7. Mengeksplorasi informasi tekstual dari deskripsi kartu.
8. Menyusun tahap preprocessing untuk membersihkan nilai placeholder, menyelaraskan tipe data, dan menyiapkan fitur turunan bagi pemodelan.

#pagebreak()

= Deskripsi Dataset

Dataset terdiri dari hasil scraping kartu Yu-Gi-Oh! dengan total:

- Jumlah observasi: 14.533 kartu
- Jumlah fitur awal: 23 kolom
- Jumlah fitur setelah pembersihan: 20 kolom

Beberapa atribut utama yang tersedia meliputi:

#align(center)[
  #table(
    columns: (2fr, 2fr, 5fr),
    stroke: 0.5pt,

    table.header(
      [*Fitur*],
      [*Atribut Data*],
      [*Deskripsi*]
    ),

    [name],
    [Nominal],
    [Nama unik kartu Yu-Gi-Oh!],

    [type],
    [Nominal],
    [Jenis kartu secara spesifik, seperti Effect Monster, Normal Monster, Spell Card, atau Trap Card],

    [frame_type],
    [Nominal],
    [Kategori utama kartu yang digunakan untuk membedakan keluarga kartu, seperti monster, spell, trap, fusion, synchro, xyz, dan link],

    [description],
    [Teks],
    [Teks efek atau deskripsi aturan kartu],

    [race],
    [Nominal],
    [Ras atau kelompok kartu, seperti Dragon, Warrior, Beast, Machine, dan lainnya],

    [attribute],
    [Nominal],
    [Atribut monster, seperti Dark, Light, Earth, Water, Fire, Wind, atau Divine],

    [archetype],
    [Nominal],
    [Kelompok tema atau seri kartu yang memiliki keterkaitan mekanik dan lore tertentu],

    [level],
    [Numerik diskrit, ordinal],
    [Level monster yang digunakan untuk mekanisme pemanggilan dan representasi kekuatan dasar monster],

    [link_value],
    [Numerik diskrit, ordinal],
    [Nilai Link pada Link Monster yang menggantikan konsep level],

    [atk],
    [Numerik diskrit, rasio],
    [Nilai Attack (ATK) yang menentukan kekuatan serangan monster],

    [def],
    [Numerik diskrit, rasio],
    [Nilai Defense (DEF) yang menentukan kemampuan bertahan monster],

    [tcgplayer_price],
    [Numerik kontinu, rasio],
    [Harga pasar kartu berdasarkan platform TCGPlayer dalam USD],

    [cardmarket_price],
    [Numerik kontinu, rasio],
    [Harga pasar kartu berdasarkan platform CardMarket dalam EUR],

    [ebay_price],
    [Numerik kontinu, rasio],
    [Harga pasar kartu berdasarkan hasil listing atau transaksi pada eBay],

    [amazon_price],
    [Numerik kontinu, rasio],
    [Harga pasar kartu berdasarkan marketplace Amazon],

    [ban_tcg],
    [Ordinal],
    [Status legalitas kartu pada format TCG, seperti Forbidden, Limited, Semi-Limited, atau Unlimited],

    [ban_ocg],
    [Ordinal],
    [Status legalitas kartu pada format Official Card Game (OCG), seperti Forbidden, Limited, Semi-Limited, atau Unlimited],

    [ban_goat],
    [Ordinal],
    [Status legalitas kartu pada format Goat Format],

    [set_count],
    [Numerik diskrit, rasio],
    [Jumlah set atau edisi produk tempat kartu tersebut pernah dicetak],

    [sets],
    [Multivalue],
    [Daftar detail seluruh set atau edisi yang memuat kartu tersebut]
  )
]

Dataset memiliki 14.533 nama kartu unik yang menunjukkan bahwa setiap observasi merepresentasikan satu kartu berbeda. Kolom rank dihapus karena seluruh nilainya kosong. Selain itu kolom image_url dan image_url_small tidak digunakan karena tidak relevan terhadap analisis numerik maupun kategorikal. 

= Analisis Missing Value

Analisis nilai hilang menunjukkan bahwa terdapat beberapa fitur dengan tingkat missing value yang cukup tinggi, terutama:

- attribute
- archetype
- level
- atk
- def
- ban_tcg
- ban_ocg
- ban_goat

#figure(
  image("output/missing_by_type.png"),
  caption: [Pola missing berdasarkan tipe kartu]
)

Hasil visualisasi menunjukkan bahwa missing value tidak terjadi secara acak, melainkan bergantung pada jenis kartu. Sebagai contoh:

- Spell Card dan Trap Card secara alami tidak memiliki atribut ATK dan DEF.
- Monster Link tidak memiliki level.
- Data ban list bersifat sangat jarang karena hanya sebagian kecil kartu yang masuk forbidden list.

Dengan demikian missing value pada dataset ini bersifat *structural missing* dan bukan akibat kesalahan pencatatan data. 



= Analisis Variabel Numerik

Analisis numerik dilakukan untuk memahami karakteristik distribusi data, mengidentifikasi pola umum, serta mendeteksi keberadaan outlier pada fitur-fitur kuantitatif dalam dataset. Variabel numerik yang dianalisis meliputi `level`, `link_value`, `atk`, `def`, `tcgplayer_price`, `cardmarket_price`, `ebay_price`, `amazon_price`, dan `set_count`.

== Statistik Deskriptif

Tabel berikut menunjukkan ringkasan statistik deskriptif untuk beberapa variabel numerik utama.

#figure(
  table(
    columns: 4,
    align: center,

    table.header(
      [*Variabel*],
      [*Mean*],
      [*Median*],
      [*Maksimum*]
    ),

    [level], [4,66], [4], [13],
    [atk], [1519,82], [1500], [5000],
    [def], [1287,50], [1200], [5000],
    [tcgplayer_price], [1,16], [0,19], [1800],
    [set_count], [3,06], [2], [78]
  ),
  caption: [Ringkasan statistik deskriptif variabel numerik]
)

Berdasarkan Tabel di atas, sebagian besar monster memiliki level sekitar 4 dengan rata-rata 4,66. Nilai ATK dan DEF memiliki median masing-masing sebesar 1500 dan 1200, menunjukkan bahwa sebagian besar monster berada pada kategori kekuatan menengah. Sementara itu, variabel harga menunjukkan perbedaan yang sangat besar antara nilai median dan nilai maksimum. Sebagai contoh, harga median pada TCGPlayer hanya sebesar \$0,19, sedangkan harga maksimum mencapai \$1800. Perbedaan yang sangat mencolok ini mengindikasikan adanya distribusi yang tidak simetris dan keberadaan sejumlah kecil kartu dengan nilai koleksi yang sangat tinggi.

== Analisis Distribusi Data

Untuk memahami bentuk distribusi setiap variabel, digunakan visualisasi *violin plot* yang mampu menunjukkan kepadatan data, sebaran, serta potensi multimodalitas.

#figure(
  image("output/numeric_violin.png"),
  caption: [Distribusi variabel numerik menggunakan violin plot]
)

Berdasarkan visualisasi pada Gambar di atas, variabel `level` memperlihatkan konsentrasi data yang kuat pada rentang level 3 hingga 8, dengan puncak kepadatan berada di sekitar level 4. Hal ini sejalan dengan mekanisme permainan Yu-Gi-Oh!, di mana sebagian besar monster umum berada pada rentang level menengah.

Variabel `atk` dan `def` menunjukkan distribusi yang relatif menyerupai bentuk lonceng (*bell-shaped distribution*) dengan konsentrasi terbesar pada rentang 1000 hingga 2500 poin. Distribusi ini menunjukkan bahwa mayoritas monster memiliki statistik yang seimbang dan hanya sebagian kecil monster yang memiliki kekuatan ekstrem.

Berbeda dengan statistik pertempuran, seluruh variabel harga (`tcgplayer_price`, `cardmarket_price`, `ebay_price`, dan `amazon_price`) menunjukkan distribusi yang sangat terkonsentrasi pada nilai rendah serta memiliki ekor distribusi yang sangat panjang ke arah kanan (*long right tail*). Pola tersebut mengindikasikan bahwa sebagian besar kartu memiliki harga yang murah, sementara hanya sejumlah kecil kartu yang bernilai sangat tinggi.

Selain itu, variabel `set_count` juga menunjukkan distribusi yang tidak simetris. Sebagian besar kartu hanya dicetak dalam satu hingga empat set, sedangkan sebagian kecil kartu populer mengalami pencetakan ulang (*reprint*) dalam jumlah yang jauh lebih banyak.

== Analisis Skewness

Tingkat kemencengan (*skewness*) distribusi diukur untuk mengetahui seberapa jauh data menyimpang dari distribusi normal. Berikut adalah beberapa nilai yang skew,

- tcgplayer_price: 68,77
- cardmarket_price: 44,97
- ebay_price: 27,26
- amazon_price: 26,29 

Nilai skewness yang sangat besar pada seluruh variabel harga menunjukkan bahwa distribusi harga tidak mengikuti distribusi normal dan didominasi oleh sejumlah kecil kartu dengan harga yang sangat tinggi. Kondisi ini umum ditemukan pada pasar barang koleksi, di mana sebagian besar item memiliki harga rendah sementara item langka dapat memiliki harga yang meningkat secara ekstrem.

== Analisis Distribusi Harga Menggunakan Skala Logaritmik

Karena distribusi harga sangat tidak seimbang, histogram pada skala logaritmik digunakan untuk memvisualisasikan pola data secara lebih jelas.

#figure(
  image("output/numeric_loghist.png"),
  caption: [Histogram logaritmik variabel harga dan jumlah cetakan]
)

Pada skala logaritmik terlihat bahwa mayoritas kartu berada pada rentang harga di bawah satu dolar. Distribusi harga membentuk pola *heavy-tailed distribution*, yaitu sebagian besar observasi terkumpul pada nilai rendah sementara sebagian kecil observasi menyebar hingga mencapai ratusan bahkan ribuan dolar.

Variabel `set_count` juga memperlihatkan fenomena serupa. Sebagian besar kartu hanya muncul dalam satu atau dua set cetakan, sedangkan sejumlah kecil kartu populer memiliki jumlah cetakan yang jauh lebih tinggi. Hal ini menunjukkan adanya ketimpangan distribusi yang cukup signifikan antara kartu umum dan kartu yang sering dicetak ulang.



= Analisis Korelasi

Analisis korelasi dilakukan untuk mengukur hubungan antar variabel numerik dalam dataset. Pada penelitian ini digunakan dua pendekatan korelasi, yaitu:

- *Pearson Correlation*, untuk mengukur hubungan linear antar variabel.
- *Spearman Correlation*, untuk mengukur hubungan berdasarkan peringkat (*rank correlation*) sehingga lebih robust terhadap outlier.

#figure(
  image("output/numeric_corr.png"),
  caption: [Perbandingan matriks korelasi Pearson dan Spearman]
)

== Hubungan Antar Statistik Pertarungan

Tabel berikut menunjukkan pasangan variabel dengan korelasi Pearson tertinggi.

#figure(
  table(
    columns: 2,
    align: center,

    table.header(
      [*Variabel*],
      [*Korelasi Pearson*]
    ),

    [ATK -- Level], [0,698],
    [Link Value -- ATK], [0,676],
    [DEF -- Level], [0,579],
    [ATK -- DEF], [0,491]
  ),
  caption: [Pasangan variabel dengan korelasi Pearson tertinggi]
)

Berdasarkan hasil korelasi, hubungan terkuat ditemukan antara `level` dan `atk` dengan nilai korelasi sebesar 0,698. Nilai ini menunjukkan adanya hubungan positif yang cukup kuat, di mana monster dengan level yang lebih tinggi cenderung memiliki nilai serangan yang lebih besar. Temuan ini konsisten dengan mekanisme permainan Yu-Gi-Oh! karena monster level tinggi umumnya dirancang memiliki statistik pertarungan yang lebih kuat dibandingkan monster level rendah.

Hubungan positif juga terlihat antara `level` dan `def` (0,579), serta antara `atk` dan `def` (0,491). Hal ini menunjukkan bahwa monster dengan kemampuan menyerang yang tinggi umumnya juga memiliki pertahanan yang relatif baik. Selain itu, `link_value` memiliki korelasi sebesar 0,676 terhadap `atk`, mengindikasikan bahwa Link Monster dengan nilai Link yang lebih tinggi cenderung memiliki kekuatan serangan yang lebih besar.

== Visualisasi Hubungan Statistik Pertarungan

#figure(
  image("output/numeric_pairplot.png", width: 70%),
  caption: [Hubungan antara Level, ATK, dan DEF]
)

Visualisasi scatter plot memperlihatkan pola korelasi positif yang cukup jelas antara ketiga variabel utama pertarungan. Hubungan antara `level` dan `atk` menunjukkan tren menaik yang konsisten, di mana peningkatan level diikuti oleh peningkatan nilai serangan. Pola serupa juga terlihat pada hubungan antara `level` dan `def`.

Pada hubungan `atk` dan `def`, meskipun terdapat penyebaran data yang lebih besar, tetap terlihat kecenderungan positif yang menunjukkan bahwa monster dengan serangan tinggi umumnya memiliki pertahanan yang lebih baik. Namun demikian, terdapat beberapa outlier yang memiliki ATK sangat tinggi tetapi DEF rendah, maupun sebaliknya. Kondisi ini mencerminkan adanya variasi desain kartu yang sengaja dibuat untuk menciptakan keseimbangan gameplay.

== Hubungan Antar Harga

Korelasi tertinggi pada kelompok fitur harga ditunjukkan pada tabel berikut.

#figure(
  table(
    columns: 2,
    align: center,

    table.header(
      [*Variabel*],
      [*Korelasi Spearman*]
    ),

    [CardMarket -- TCGPlayer], [0,728],
    [Amazon -- Ebay], [0,619]
  ),
  caption: [Korelasi tertinggi antar platform harga]
)

Nilai korelasi Spearman sebesar 0,728 antara `cardmarket_price` dan `tcgplayer_price` menunjukkan bahwa kartu yang mahal pada satu marketplace cenderung juga memiliki harga tinggi pada marketplace lainnya. Korelasi ini cukup kuat karena kedua platform merefleksikan nilai pasar yang relatif serupa.

Sementara itu, korelasi antara `amazon_price` dan `ebay_price` sebesar 0,619 menunjukkan hubungan positif yang moderat. Namun korelasi Pearson pada beberapa pasangan harga cenderung lebih rendah dibandingkan Spearman. Hal ini mengindikasikan bahwa urutan harga antar kartu relatif konsisten, tetapi nilai nominalnya dapat berbeda cukup jauh akibat adanya kartu-kartu dengan harga ekstrem atau kartu kolektor yang sangat langka.

== Hubungan Statistik Permainan dan Harga

Menariknya, hampir seluruh korelasi antara statistik permainan (`ATK`, `DEF`, `Level`, dan `Link Value`) dengan variabel harga berada di bawah 0,20. Nilai korelasi yang sangat rendah ini menunjukkan bahwa kekuatan kartu dalam permainan tidak menjadi faktor utama yang menentukan nilai ekonominya.

Temuan ini mengindikasikan bahwa harga kartu Yu-Gi-Oh! lebih banyak dipengaruhi oleh faktor eksternal seperti:

- Kelangkaan kartu (*rarity*).
- Jumlah cetakan ulang (*reprint*).
- Popularitas archetype.
- Permintaan komunitas pemain.
- Status legalitas pada format kompetitif.
- Nilai koleksi historis.

Dengan kata lain, kartu yang sangat kuat dalam permainan belum tentu memiliki harga yang mahal, begitu pula kartu dengan harga sangat tinggi belum tentu memiliki statistik pertarungan yang unggul.


= Analisis Outlier

Deteksi outlier dilakukan menggunakan metode *Interquartile Range* (IQR), yaitu dengan mengidentifikasi observasi yang berada di luar rentang:

$
[Q_1 - 1.5 upright("IQR"),
 Q_3 + 1.5 upright("IQR")]
$


Metode ini dipilih karena cukup robust terhadap distribusi data yang tidak normal dan mampu mengidentifikasi nilai ekstrem pada fitur numerik.

== Proporsi Outlier

Tabel berikut menunjukkan persentase outlier pada variabel yang memiliki jumlah outlier terbesar.

#figure(
  table(
    columns: 2,
    align: center,

    table.header(
      [*Variabel*],
      [*Persentase Outlier*]
    ),

    [cardmarket_price], [13,48\%],
    [amazon_price], [13,25\%],
    [tcgplayer_price], [13,23\%],
    [ebay_price], [12,09\%]
  ),
  caption: [Persentase outlier berdasarkan metode IQR]
)

Berdasarkan hasil deteksi outlier, seluruh variabel harga memiliki proporsi outlier yang relatif tinggi dibandingkan fitur numerik lainnya. Kondisi ini menunjukkan bahwa distribusi harga kartu memiliki ekor distribusi yang sangat panjang (*heavy-tailed distribution*), di mana sebagian besar kartu memiliki harga rendah sementara sejumlah kecil kartu memiliki harga yang sangat tinggi.

== Distribusi Harga dan Outlier

#figure(
  image("output/numeric_price_zoom.png"),
  caption: [Distribusi harga TCGPlayer dengan median dan persentil ke-99]
)

Pada Gambar di atas terlihat bahwa median harga kartu hanya sebesar \$0,19, sedangkan persentil ke-99 berada pada kisaran \$11,44. Perbedaan yang sangat besar antara nilai tengah dan nilai ekstrem menunjukkan adanya ketimpangan distribusi harga yang signifikan.

Sebagian besar kartu berada pada rentang harga di bawah satu dolar, sementara hanya sebagian kecil kartu yang memiliki harga puluhan, ratusan, bahkan ribuan dolar. Fenomena ini merupakan karakteristik umum pasar TCG, di mana kartu langka dan kartu koleksi memiliki nilai yang jauh lebih tinggi dibandingkan kartu biasa.

Dengan demikian, outlier yang ditemukan pada fitur harga tidak dapat dianggap sebagai kesalahan data (*data error*), melainkan representasi dari kondisi pasar yang sesungguhnya.

== Kartu Termahal dalam Dataset

Untuk memahami sumber munculnya outlier harga, dilakukan identifikasi kartu dengan harga tertinggi berdasarkan platform TCGPlayer.

#figure(
  table(
    columns: 3,
    align: center,

    table.header(
      [*Nama Kartu*],
      [*Tipe*],
      [*Harga TCGPlayer (USD)*]
    ),

    [Blood Mefist], [Synchro Monster], [1800,00],
    [Ten Thousand Dragon], [Effect Monster], [718,19],
    [Chimaera, the Master of Beasts], [Effect Monster], [575,00],
    [Anotherverse Solaria], [Normal Monster], [370,02],
    [Garma Sword], [Ritual Monster], [367,00]
  ),
  caption: [Lima kartu dengan harga TCGPlayer tertinggi]
)

Terlihat bahwa harga kartu termahal mencapai \$1800, jauh di atas mayoritas kartu dalam dataset. Nilai yang sangat tinggi inilah yang menyebabkan distribusi harga menjadi sangat *right-skewed* dan menghasilkan banyak observasi yang terdeteksi sebagai outlier oleh metode IQR.

== Kartu dengan ATK Tertinggi

Selain harga, analisis juga dilakukan terhadap nilai serangan (*Attack/ATK*) untuk mengidentifikasi monster dengan statistik pertarungan tertinggi.

#figure(
  table(
    columns: 3,
    align: center,

    table.header(
      [*Nama Kartu*],
      [*Tipe*],
      [*ATK*]
    ),

    [Cyberdark End Dragon], [Fusion Monster], [5000],
    [Dragon Master Knight], [Fusion Monster], [5000],
    [Dragon Master Lords], [XYZ Monster], [5000],
    [Dragon Master Magia], [Fusion Monster], [5000],
    [Drytron Meteonis DA Draconids], [Ritual Effect Monster], [5000]
  ),
  caption: [Lima kartu dengan nilai ATK tertinggi]
)

Menariknya, outlier pada statistik pertarungan jauh lebih sedikit dibandingkan outlier pada harga. Nilai ATK maksimum pada dataset adalah 5000, yang merupakan batas atas yang jarang ditemukan dalam permainan. Kartu-kartu tersebut umumnya merupakan monster boss dengan syarat pemanggilan yang kompleks sehingga keberadaannya memang dirancang sebagai pengecualian dalam permainan.


= Analisis Variabel Kategorikal

Selain variabel numerik, dataset juga memiliki sejumlah fitur kategorikal yang berperan penting dalam mendeskripsikan karakteristik kartu Yu-Gi-Oh!. Analisis terhadap fitur kategorikal dilakukan untuk memahami keragaman data, distribusi kategori dominan, serta potensi fitur yang dapat digunakan pada tahap pemodelan.

== Kardinalitas Kategori

Tabel berikut menunjukkan jumlah kategori unik pada beberapa fitur kategorikal utama.

#figure(
  table(
    columns: 2,
    align: center,

    table.header(
      [*Fitur*],
      [*Jumlah Kategori*]
    ),

    [Archetype], [659],
    [Race], [86],
    [Type], [29],
    [Frame Type], [17]
  ),
  caption: [Jumlah kategori unik pada fitur kategorikal]
)

Berdasarkan tabel di atas, fitur `archetype` memiliki tingkat keragaman tertinggi dengan 659 kategori unik, diikuti oleh `race` sebanyak 86 kategori. Tingginya jumlah kategori ini menunjukkan bahwa dataset memiliki variasi kartu yang sangat besar. 

== Distribusi Tipe Kartu

Berdasarkan distribusi kategori, tipe kartu yang paling banyak ditemukan dalam dataset adalah:

- Effect Monster (35,3%)
- Spell Card
- Trap Card

Dominasi kartu bertipe *Effect Monster* menunjukkan bahwa sebagian besar kartu dalam permainan modern Yu-Gi-Oh! mengandalkan efek khusus dibandingkan hanya mengandalkan statistik dasar seperti ATK dan DEF. Kondisi ini sejalan dengan perkembangan mekanisme permainan yang semakin kompleks dan berorientasi pada kombinasi efek antar kartu.

== Analisis Race dan Archetype

#figure(
  image("output/categorical_race_archetype.png"),
  caption: [Distribusi 15 race dan archetype paling banyak muncul]
)

Visualisasi menunjukkan bahwa kategori `race` didominasi oleh kelompok seperti *Warrior*, *Machine*, *Fiend*, *Dragon*, dan *Spellcaster*. Dominasi kategori tersebut cukup masuk akal karena sebagian besar monster populer dalam serial Yu-Gi-Oh! berasal dari ras-ras tersebut.

Pada fitur `archetype`, terlihat bahwa *Elemental HERO* merupakan archetype yang paling banyak muncul dalam dataset, diikuti oleh *Archfiend* dan *Performapal*. Ketiga archetype tersebut merupakan tema kartu yang cukup populer dan memiliki banyak varian kartu. Hal ini selaras karena archetype tersebut digunakan dalam deck milik main character pada series anime. 

Menariknya, sekitar 39,5% kartu dalam dataset tidak memiliki archetype tertentu. Hal ini menunjukkan bahwa tidak semua kartu dirancang sebagai bagian dari suatu tema atau strategi deck tertentu. Oleh karena itu, nilai kosong (*missing value*) pada fitur archetype tidak selalu menunjukkan kualitas data yang buruk, melainkan merupakan karakteristik alami dari desain kartu Yu-Gi-Oh!.

== Analisis Ban List

#figure(
  image("output/categorical_bans.png"),
  caption: [Distribusi status legalitas kartu pada berbagai format permainan]
)

Analisis terhadap fitur `ban_tcg`, `ban_ocg`, dan `ban_goat` menunjukkan bahwa sebagian besar kartu berstatus *Unlimited*. Kartu yang berstatus *Forbidden*, *Limited*, maupun *Semi-Limited* hanya mencakup sebagian kecil dari keseluruhan dataset.

Hal ini menunjukkan bahwa mayoritas kartu tetap dapat digunakan secara bebas dalam format permainan resmi, sedangkan hanya sejumlah kecil kartu yang dibatasi karena berpotensi menciptakan ketidakseimbangan permainan.

Selain itu, distribusi status ban pada masing-masing *frame type* memperlihatkan bahwa kartu bertipe *Effect Monster*, *Spell Card*, dan *Link Monster* memiliki jumlah kartu terlarang yang relatif lebih tinggi dibandingkan tipe lainnya. Temuan ini mengindikasikan bahwa kartu-kartu dengan efek kompleks atau kemampuan combo yang kuat lebih berpotensi masuk ke dalam daftar pembatasan kompetitif.


= Analisis Teks

Selain fitur numerik dan kategorikal, dataset juga memiliki fitur tekstual berupa deskripsi efek kartu (*card effect text*) dan nama kartu. Analisis teks dilakukan untuk memahami karakteristik bahasa yang digunakan pada kartu Yu-Gi-Oh! serta mengidentifikasi potensi informasi yang dapat dimanfaatkan pada proses *Natural Language Processing* (NLP).

== Statistik Panjang Teks

Statistik deskriptif panjang deskripsi kartu ditunjukkan pada tabel berikut.

#figure(
  table(
    columns: 2,
    align: center,

    table.header(
      [*Metrik*],
      [*Nilai*]
    ),

    [Rata-rata karakter], [313],
    [Rata-rata kata], [56],
    [Maksimum karakter], [1006],
    [Maksimum kata], [188]
  ),
  caption: [Statistik panjang deskripsi kartu]
)

#figure(
  image("output/nlp_lengths.png"),
  caption: [Distribusi panjang deskripsi kartu]
)

Berdasarkan visualisasi di atas, panjang deskripsi kartu memiliki rata-rata sekitar 313 karakter atau 56 kata per kartu. Distribusi panjang teks menunjukkan bahwa sebagian besar kartu memiliki deskripsi antara 20 hingga 100 kata, meskipun terdapat beberapa kartu dengan deskripsi yang jauh lebih panjang.

Perbedaan panjang deskripsi juga terlihat antar tipe kartu. Kartu bertipe *Effect Monster*, *Fusion Monster*, dan *XYZ Monster* cenderung memiliki teks yang lebih panjang dibandingkan kartu monster normal. Hal ini menunjukkan bahwa kartu-kartu tersebut umumnya memiliki efek yang lebih kompleks dan membutuhkan penjelasan aturan yang lebih rinci. Temuan ini juga selaras dengan KONAMI sebagai publisher yang belajar kesalahan dalam penulisan kartu forbidden sebelumnya yang seringkali tidak mengikutsertakan kalimat kondisional seperti, "Once a Turn", "You can only use this effect of "Dark Magician of Chaos" once per turn" dan lain sebagainya. Sebaliknya, *Normal Monster* memiliki panjang deskripsi yang jauh lebih pendek karena sebagian besar hanya berisi teks flavor atau deskripsi karakter tanpa efek pada duel. 

== Analisis Kata Dominan pada Nama Kartu

Untuk memahami tema yang paling sering muncul dalam desain kartu, dilakukan analisis frekuensi kata pada nama kartu.

#figure(
  image("output/name_wordcloud.png"),
  caption: [Word cloud nama kartu Yu-Gi-Oh!]
)

Berdasarkan visualisasi *word cloud*, kata *Dragon* merupakan kata yang paling dominan dan muncul sebanyak 804 kali dalam nama kartu. Selain itu, kata-kata seperti *Dark*, *Knight*, *Beast*, *Hero*, *Archfiend*, dan *Token* juga memiliki frekuensi yang tinggi.

Dominasi kata *Dragon* menunjukkan bahwa monster bertema naga merupakan salah satu tema paling populer dalam permainan Yu-Gi-Oh!. Hal ini sejalan dengan keberadaan berbagai kartu ikonik seperti Blue-Eyes White Dragon dan Red-Eyes Black Dragon yang telah menjadi bagian penting dari identitas permainan sejak awal.

Selain itu, munculnya kata-kata seperti *Dark*, *Knight*, *Chaos*, dan *Hero* menunjukkan bahwa sebagian besar desain kartu menggunakan kosakata bertema fantasi, petualangan, dan peperangan. Pola ini mengindikasikan bahwa nama kartu tidak hanya berfungsi sebagai identitas, tetapi juga mencerminkan tema, ras, dan lore dari kartu tersebut.

== Analisis Kata Dominan pada Deskripsi

Analisis frekuensi kata pada deskripsi kartu menunjukkan bahwa beberapa kata muncul jauh lebih sering dibandingkan kata lainnya. Kata yang paling sering ditemukan meliputi:

- card
- monster
- turn
- effect
- special
- summon
- opponent
- hand
- deck

Kata-kata tersebut secara langsung merepresentasikan mekanisme inti permainan Yu-Gi-Oh!. Kemunculan kata *special summon* yang sangat dominan menunjukkan bahwa mekanisme pemanggilan khusus merupakan salah satu elemen utama dalam strategi permainan modern. Sementara itu, kata seperti *deck*, *hand*, *opponent*, dan *effect* menggambarkan interaksi yang terjadi antara pemain, kartu, dan kondisi permainan.

#pagebreak()

= Preprocessing Data

Tahap preprocessing dilakukan setelah eksplorasi data agar setiap keputusan tercatat dan dapat diaudit, bukan dilakukan secara diam-diam. Fokusnya adalah memastikan bahwa nilai yang bukan hasil observasi nyata tidak diperlakukan sebagai data valid, lalu mengubah dataset mentah menjadi tabel data yang siap dipakai pada tahap pemodelan. Hasil akhirnya adalah satu tabel data bersih dengan 14.533 baris tanpa ada baris yang dihapus dan 57 kolom, ditambah satu tabel rilisan panjang dengan 44.517 baris.

== Permasalahan pada Data Mentah

Profil data mentah, heatmap missing value, dan ringkasan statistik menunjukkan sembilan masalah yang akan mendistorsi analisis maupun pemodelan berikutnya.

#figure(
  table(
    columns: (4fr, 4fr, 6fr),
    align: left,
    stroke: 0.5pt,

    table.header(
      [*Permasalahan*],
      [*Bukti pada data*],
      [*Tindakan*]
    ),

    [Kolom `rank` kosong], [0 nilai non-null], [Dihapus bersama `image_url` dan `image_url_small`],
    [Harga \$0,00 berarti tidak ada listing], [504 sampai 2.581 baris per marketplace], [Diubah menjadi missing value],
    [`atk` dan `def` bernilai -1], [84 dan 55 baris], [Diubah menjadi missing value],
    [`level` bernilai 0], [115 baris, sebagian besar Link Monster], [Diubah menjadi missing value],
    [Id kartu dipakai sebagai index bertipe teks], [Kolom `id` hilang setelah dipakai sebagai index], [Dikembalikan menjadi kolom `card_id` bertipe integer],
    [Kolom `sets` menyimpan daftar Python sebagai teks], [Nilai diawali `[` dan `{`], [Diurai menjadi tabel rilisan],
    [Atribut kosong pada seluruh kartu non-monster], [5.190 baris], [Diisi `None` dan ditandai `is_monster`],
    [659 kategori archetype dengan 39,5\% kosong], [Audit kardinalitas], [Top-15 grouping dan frequency encoding],
    [Kolom ban list kosong hampir seluruhnya], [73 sampai 222 baris non-null], [Diisi `Unlimited`, lalu dijadikan severity dan flag],
  ),
  caption: [Permasalahan pada data mentah dan tindakan penanganannya]
)

Tiga kolom yang telah dibahas pada bagian Deskripsi Dataset, yaitu `rank`, `image_url`, dan `image_url_small`, tidak dihitung sebagai masalah preprocessing karena sudah dihapus sejak dataset dibaca. Fokus pada tabel di atas adalah bahwa sembilan masalah sisanya bersifat sistemik dan berasal dari cara database sumber menyimpan data, bukan dari kesalahan pencatatan.

== Nilai Placeholder menjadi Missing Value

Database YGOPRODeck tidak menggunakan sel kosong untuk menandai kondisi tanpa nilai, melainkan memakai angka placeholder. Harga \$0,00 berarti kartu tidak memiliki listing pada marketplace tersebut, nilai -1 pada `atk` dan `def` berarti angka tersebut tidak dicetak pada kartu fisik, dan level 0 menandai monster yang memang tidak memiliki level seperti Link Monster. Jika angka placeholder ini diperlakukan sebagai observasi biasa, seluruh rata-rata, korelasi, dan histogram akan terdorong mendekati nol.

#figure(
  table(
    columns: (3fr, 3fr, 6fr, 2fr),
    align: left,
    stroke: 0.5pt,

    table.header(
      [*Kolom*],
      [*Placeholder*],
      [*Makna*],
      [*Baris diubah*]
    ),

    [tcgplayer_price], [0], [Tidak ada listing pada TCGPlayer], [530],
    [cardmarket_price], [0], [Tidak ada listing pada CardMarket], [504],
    [ebay_price], [0], [Tidak ada listing pada eBay], [2.290],
    [amazon_price], [0], [Tidak ada listing pada Amazon], [2.581],
    [level], [0], [Monster tanpa level, misalnya Link Monster], [115],
    [atk], [-1], [Nilai serangan tidak dicetak pada kartu], [84],
    [def], [-1], [Nilai pertahanan tidak dicetak pada kartu], [55],
  ),
  caption: [Konversi nilai placeholder menjadi missing value]
)

Sebaliknya, nilai `atk` bernilai 0 tetap dipertahankan karena monster dengan serangan nol memang ada dalam permainan, sehingga tidak dapat dianggap sebagai placeholder. Setelah placeholder dihilangkan, nilai skewness harga turun sedikit menjadi 67,51, 44,19, 25,08, dan 23,97, karena 256 kartu yang sebelumnya tercatat \$0,00 pada keempat marketplace tidak lagi menarik rata-rata ke arah nol. Perbandingan distribusi tersebut divisualisasikan pada Gambar di bawah.

#figure(
  image("output/preprocessing_price_transform.png"),
  caption: [Distribusi harga TCGPlayer sebelum dan sesudah preprocessing]
)

== Missing Value Struktural dan Flag Taxonomi Kartu

Sebagian besar missing value pada dataset ini bersifat struktural, yaitu memang tidak ada pada sekelompok kartu tertentu. Mengisi nilai kosong dengan angka hasil interpolasi akan menciptakan data yang tidak pernah ada, sehingga tabel data dibiarkan tetap memiliki nilai kosong dan alasannya dicatat melalui beberapa fitur turunan. Fitur `is_monster` dan `card_kind` menandai kelompok kartu, `is_pendulum` menandai monster pendulum, dan kolom `attribute` dilengkapi dengan kategori `None` agar tidak memiliki celah pada fitur kategorikal.

#figure(
  table(
    columns: 3,
    align: center,
    stroke: 0.5pt,

    table.header(
      [*Kelompok Kartu*],
      [*Jumlah Kartu*],
      [*Persentase*]
    ),

    [Monster], [9.344], [64,3\%],
    [Spell], [2.878], [19,8\%],
    [Trap], [2.081], [14,3\%],
    [Skill], [124], [0,9\%],
    [Token], [106], [0,7\%],
  ),
  caption: [Pengelompokan kartu berdasarkan card kind]
)

Verifikasi struktural menunjukkan bahwa tidak ada satu pun dari 5.189 kartu non-monster yang memiliki level, ATK, atau link value, sehingga tidak ada missing value struktural yang perlu diimputasi. Setelah atribut dilengkapi, hanya tersisa satu kartu monster tanpa atribut, yaitu kasus missing value yang benar-benar tidak terstruktur.

== Pembersihan Kolom Teks

Sebagian nama kartu masih menyimpan tanda kutip dekoratif seperti `"A" Cell Breeding Device`, dan 3.601 deskripsi masih memuat baris baru hasil scraping halaman web. Keduanya dinormalisasi dengan menghapus tanda kutip dan menyatukan spasi berlebih, sehingga jumlah nama kartu dengan tanda kutip turun dari 83 menjadi 0 dan jumlah deskripsi dengan baris baru turun dari 3.601 menjadi 0. Total karakter pada kolom nama berkurang dari 278.043 menjadi 277.877 karakter, sedangkan pada kolom deskripsi dari 4.556.110 menjadi 4.550.779 karakter. Pembersihan ini penting karena tanda kutip dan spasi berlebih akan mendistorsi tokenisasi, baris kata, dan *word cloud* pada bagian analisis teks.

== Parsing Kolom sets dan Feature Rilisan

Kolom `sets` menyimpan daftar Python sebagai teks dengan tanda kutip tunggal, sehingga `json.loads` tidak dapat mengurai isinya. Karena itu parser `ast.literal_eval` digunakan dan hasilnya dipecah menjadi tabel rilisan dengan kolom `card_id`, `set_name`, `set_code`, `set_rarity`, `set_rarity_code`, dan `set_price`.

#figure(
  table(
    columns: (7fr, 3fr),
    align: left,
    stroke: 0.5pt,

    table.header(
      [*Keterangan Tabel Rilisan*],
      [*Nilai*]
    ),

    [Baris rilisan hasil parsing], [44.517],
    [Kartu yang tercakup], [14.014],
    [Kartu tanpa rilisan], [519],
    [Rilisan yang memiliki harga], [12.363],
    [Awalan set yang berbeda], [661],
    [Kode raritas yang berbeda], [30],
  ),
  caption: [Ringkasan tabel rilisan hasil parsing kolom sets]
)

Jumlah rilisan hasil parsing selalu sama dengan nilai `set_count` pada seluruh 14.533 kartu, sehingga konsistensi internal dataset terverifikasi. Fitur turunan yang dihasilkan antara lain `n_set_entries`, `n_set_codes`, `n_rarities`, `set_price_max`, `set_price_median`, dan `is_reprint`. Harga rilisan yang bernilai 0 diperlakukan sebagai placeholder yang sama dengan harga marketplace. Ekor harga rilisan sangat ekstrem, yaitu mencapai \$115.033,33 untuk kartu Shonen Jump Championship 2007 Prize Card A, sementara median harga rilisan hanya \$1,78. Hal ini menunjukkan bahwa kolom harga rilisan menggambarkan kelangkaan dari sebuah cetakan, bukan harga pasar yang dapat dibandingkan langsung antar marketplace.

== Encoding Kolom Kategorikal

Tiga fitur kategorikal tidak dapat dipakai apa adanya karena jumlah kategorinya terlalu besar atau terlalu jarang terisi. `race` dengan 86 kategori dan `archetype` dengan 659 kategori dikelompokkan dengan mempertahankan 15 kategori paling sering muncul, sedangkan sisanya digabung menjadi kategori `Other`.

#figure(
  table(
    columns: 3,
    align: center,
    stroke: 0.5pt,

    table.header(
      [*Fitur*],
      [*Kategori Sebelum*],
      [*Kategori Setelah*]
    ),

    [race], [86], [17 (`race_grouped`)],
    [archetype], [659], [17 (`archetype_grouped`)],
    [ban_tcg], [3, 98,47\% kosong], [4 status terisi],
  ),
  caption: [Pengelompokan kategori dengan kardinalitas tinggi]
)

Agar informasi jumlah kemunculan tidak hilang setelah pengelompokan, frekuensi setiap kategori disimpan pada kolom `race_freq` dan `archetype_freq`. Untuk ban list, sel kosong diisi dengan status `Unlimited` karena status tersebut memang ada pada setiap kartu, bukan berarti data tidak tersedia. Distribusi `ban_tcg` setelah pengisian terdiri atas 14.311 kartu *Unlimited*, 95 *Limited*, 10 *Semi-Limited*, dan 117 *Forbidden*, sehingga hanya 1,5\% kartu yang dibatasi dan 0,8\% yang dilarang. Setiap format ban list juga diturunkan menjadi tingkat severity bertipe ordinal dan dua flag boolean, yaitu flag *restricted* dan *forbidden*.

== Transformasi Distribusi Harga yang Skewed

Setelah placeholder dihilangkan, distribusi harga tetap terkonsentrasi pada nilai rendah dengan ekor kanan yang panjang. Oleh karena itu ditambahkan kolom `log1p` untuk setiap kolom harga dan untuk `set_count`, sehingga model linear dapat melihat fitur yang lebih simetris.

#figure(
  table(
    columns: 3,
    align: center,
    stroke: 0.5pt,

    table.header(
      [*Variabel*],
      [*Skewness Sebelum*],
      [*Skewness Setelah log1p*]
    ),

    [tcgplayer_price], [67,51], [4,80],
    [cardmarket_price], [44,19], [4,67],
    [ebay_price], [25,08], [2,69],
    [amazon_price], [23,97], [2,05],
    [set_count], [5,54], [0,75],
  ),
  caption: [Pengaruh transformasi log1p terhadap kemencengan distribusi]
)

Outlier harga tidak dihapus karena kartu bernilai tinggi merupakan informasi nyata tentang pasar koleksi. Sebagai gantinya, flag boolean `is_whale_*` menandai satu persen teratas pada setiap marketplace, yaitu 141, 141, 123, dan 152 kartu. Karena keempat marketplace tidak mencantumkan kartu yang sama, ditambahkan pula ringkasan lintas marketplace berupa `n_price_sources` dengan rata-rata 3,59 dari empat marketplace, serta `price_min`, `price_median`, dan `price_max` per kartu. Fitur ini penting karena 256 kartu tidak memiliki harga sama sekali pada keempat marketplace.

== Verifikasi Hasil Preprocessing

Setiap aturan di atas diverifikasi secara programatis, bukan diasumsikan benar.

#figure(
  table(
    columns: (8fr, 3fr),
    align: left,
    stroke: 0.5pt,

    table.header(
      [*Pemeriksaan*],
      [*Hasil*]
    ),

    [Jumlah baris sebelum dan sesudah], [14.533, tidak ada baris dihapus],
    [Jumlah kolom tabel data bersih], [57],
    [Duplikat `card_id`], [0],
    [Duplikat `name`], [0],
    [Harga bernilai 0 yang tersisa], [0],
    [Harga negatif yang tersisa], [0],
    [Level bernilai 0 yang tersisa], [0],
    [ATK atau DEF negatif yang tersisa], [0],
    [Ketidaksesuaian `set_count` dengan rilisan], [0],
    [Kartu tanpa harga sama sekali], [256],
    [Sel teks kosong], [0],
    [Ukuran memori tabel data bersih], [21,09 MB],
  ),
  caption: [Verifikasi integritas tabel data bersih]
)

Dengan demikian tabel data bersih yang dihasilkan sudah siap digunakan pada tahap pemodelan, dengan tiga kelompok fitur utama, yaitu statistik pertarungan bertipe integer yang tetap menyimpan nilai kosong secara akurat, harga yang telah dilogaritmikkan beserta flag *whale*, serta informasi rilisan dalam bentuk ringkasan per kartu. Tabel data bersih disimpan pada `output/yugioh_cards_clean.csv` dan tabel rilisan pada `output/card_releases_long.csv`.

