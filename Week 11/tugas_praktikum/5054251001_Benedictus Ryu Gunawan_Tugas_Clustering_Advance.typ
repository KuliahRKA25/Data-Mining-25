
// ============================================
// KONFIGURASI DOKUMEN
// ============================================
#set document(
  title: "Laporan Clustering Lanjutan pada Dataset Palmer Penguins",
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
  #text(size: 18pt, weight: "bold")[TUGAS - WEEK 11]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[LAPORAN CLUSTERING LANJUTAN PADA DATASET PALMER PENGUINS]
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

Clustering adalah teknik pembelajaran tanpa pengawasan yang mengelompokkan data berdasarkan kemiripan. Pada praktikum ini dipakai empat pendekatan yang berbeda: Agglomerative Clustering yang bersifat hierarkis, DBSCAN yang berbasis kepadatan, Gaussian Mixture Model (GMM) yang berbasis model probabilistik, dan Spectral Clustering yang berbasis graf. Perbedaan cara kerja tersebut membuat keempat algoritma dapat menghasilkan partisi yang berbeda pada data yang sama.

Dataset Palmer Penguins berisi pengukuran fisik penguin dari Kepulauan Palmer, Antartika. Empat kolom numerik, yaitu `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`, dan `body_mass_g`, dipakai sebagai fitur clustering. Kolom `species` tidak dipakai saat clustering dan hanya dipakai sebagai label pembanding pada evaluasi eksternal. Karena satuan fitur berbeda jauh, seluruh algoritma dijalankan pada data hasil standardisasi z-score.

== Tujuan

Tujuan praktikum ini adalah:

1. Memahami konsep hierarchical, density-based, model-based, dan spectral clustering.
2. Menerapkan keempat algoritma pada dataset Palmer Penguins dan membandingkan hasilnya.
3. Mengevaluasi hasil dengan Silhouette Score, Rand Index, dan Normalized Mutual Information (NMI).
4. Menguji kestabilan hasil terhadap perubahan kecil pada dataset.
5. Menentukan algoritma yang paling cocok untuk dataset ini beserta alasannya.

Alur kerja mengikuti notebook tugas yang disertakan pada folder ini. Seluruh gambar dan tabel pada laporan ini dihasilkan oleh notebook tersebut dan tersimpan pada folder `output/`.

= Deskripsi Dataset

Dataset dibaca langsung dari URL resmi Palmer Penguins. Data mentah berisi 344 baris dan 8 kolom. Setiap baris adalah satu pengukuran penguin, dengan tiga spesies, tiga pulau, dan periode pengamatan 2007 sampai 2009.

#figure(
  table(
    columns: (2.2fr, 3fr),
    stroke: 0.5pt,
    table.header([*Atribut*], [*Nilai*]),
    [Baris mentah], [344],
    [Kolom], [8],
    [Baris bersih], [342],
    [Fitur clustering], [4 kolom numerik],
    [Spesies], [Adelie, Chinstrap, Gentoo],
    [Pulau], [Biscoe, Dream, Torgersen],
    [Tahun pengamatan], [2007 sampai 2009],
    [Missing pada fitur], [2 baris],
    [Missing pada sex], [11 baris],
  ),
  caption: [Ringkasan dataset Palmer Penguins]
)

#figure(
  table(
    columns: (2.4fr, 1fr),
    align: (left, right),
    stroke: 0.5pt,
    table.header([*Kolom*], [*Nilai kosong*]),
    [`species`], [0],
    [`island`], [0],
    [`bill_length_mm`], [2],
    [`bill_depth_mm`], [2],
    [`flipper_length_mm`], [2],
    [`body_mass_g`], [2],
    [`sex`], [11],
    [`year`], [0],
  ),
  caption: [Jumlah nilai kosong per kolom pada data mentah]
)

Kolom `species` tidak memiliki nilai kosong. Dua baris memiliki nilai kosong pada keempat fitur numerik sekaligus, sehingga kedua baris tersebut dihapus. Kolom `sex` memiliki 11 nilai kosong, tetapi tidak dipakai dalam clustering sehingga tidak menjadi dasar penghapusan. Setelah pembersihan, data berisi 342 baris.

= Eksplorasi dan Pembersihan Data

== Pembersihan dan Komposisi Spesies

Pembersihan dilakukan dengan menghapus baris yang kosong pada salah satu dari empat fitur numerik atau pada kolom `species`. Jumlah baris turun dari 344 menjadi 342, atau 2 baris (0,58\%). Komposisi spesies setelah pembersihan adalah Adelie 151 (44,15\%), Chinstrap 68 (19,88\%), dan Gentoo 123 (35,96\%).

#figure(
  table(
    columns: (3fr, 1fr, 1fr),
    align: (left, right, right),
    stroke: 0.5pt,
    table.header([*Tahap*], [*Baris*], [*Baris dihapus*]),
    [Data mentah], [344], [0],
    [Hapus missing fitur atau species], [342], [2],
  ),
  caption: [Ringkasan pembersihan data]
)

#figure(
  table(
    columns: (2fr, 1fr, 1fr),
    align: (left, right, right),
    stroke: 0.5pt,
    table.header([*Spesies*], [*Jumlah*], [*Persentase*]),
    [Adelie], [151], [44,15\%],
    [Gentoo], [123], [35,96\%],
    [Chinstrap], [68], [19,88\%],
  ),
  caption: [Jumlah data per spesies setelah pembersihan]
)

#figure(
  image("output/missing_values.png", width: 82%),
  caption: [Jumlah nilai kosong per kolom. Kolom sex memiliki nilai kosong terbanyak, tetapi tidak dipakai dalam clustering.],
) <fig-missing>

== Statistik Deskriptif dan Sebaran Awal

Perbedaan skala antar fitur sangat besar. `body_mass_g` memiliki simpangan baku 801,95 gram, sedangkan `bill_depth_mm` hanya 1,97 milimeter. Rasio simpangan baku terbesar terhadap terkecil sekitar 407 kali. Tanpa standardisasi, jarak Euclidean akan didominasi oleh massa tubuh dan algoritma berbasis jarak dapat menghasilkan kluster yang bias.

#figure(
  table(
    columns: (2.5fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    stroke: 0.5pt,
    table.header([*Fitur*], [*Mean*], [*Std*], [*Min*], [*Max*]),
    [`bill_length_mm`], [43,92], [5,46], [32,10], [59,60],
    [`bill_depth_mm`], [17,15], [1,97], [13,10], [21,50],
    [`flipper_length_mm`], [200,92], [14,06], [172,00], [231,00],
    [`body_mass_g`], [4.201,75], [801,95], [2.700,00], [6.300,00],
  ),
  caption: [Statistik deskriptif empat fitur clustering]
)

#figure(
  image("output/initial_scatter.png", width: 100%),
  caption: [Scatter plot awal bill_length_mm terhadap flipper_length_mm. Panel kanan hanya memberi warna berdasarkan spesies sebagai referensi, bukan input clustering.],
) <fig-initial>

== Standardisasi Data

StandardScaler mengubah setiap fitur menjadi z-score dengan rata-rata 0 dan simpangan baku 1. Setelah standardisasi, keempat fitur memiliki skala yang setara sehingga jarak antar titik tidak lagi didominasi oleh fitur dengan satuan besar. Seluruh algoritma pada laporan ini dijalankan pada matriks `X_scaled` berukuran 342 x 4.

#figure(
  image("output/scaling_comparison.png", width: 100%),
  caption: [Perbandingan distribusi fitur sebelum dan sesudah standardisasi. Skala gram dan milimeter disetarakan menjadi z-score.],
) <fig-scaling>

= Penerapan Algoritma

== Agglomerative Clustering

Agglomerative Clustering dijalankan dengan tiga kluster dan Ward linkage. Ward linkage menggabungkan dua kluster yang meminimalkan kenaikan total variansi dalam kluster. Dendrogram berikut menunjukkan struktur penggabungan dan garis potong untuk tiga kluster.

#figure(
  image("output/dendrogram.png", width: 100%),
  caption: [Dendrogram Agglomerative Clustering dengan Ward linkage. Garis putus-putus menandai potongan untuk tiga kluster.],
) <fig-dendrogram>

Agglomerative Ward menghasilkan kluster berukuran 162, 123, dan 57. Kluster berukuran 123 seluruhnya berisi Gentoo. Kluster berukuran 162 berisi 151 Adelie dan 11 Chinstrap, sedangkan kluster berukuran 57 berisi 57 Chinstrap. Dengan demikian, Gentoo terpisah sempurna, tetapi 11 Chinstrap masih bergabung dengan Adelie. Silhouette Score-nya 0,454, Rand Index 0,961, dan NMI 0,901.

== DBSCAN

DBSCAN dimulai dari `eps=0.5` dan `min_samples=5`. Pada nilai tersebut dihasilkan 4 kluster dan 69 titik noise. Nilai eps kemudian diuji pada beberapa nilai lain. Tabel berikut merangkum jumlah kluster, jumlah noise, Silhouette Score, Rand Index, dan NMI untuk nilai eps yang dipilih.

#figure(
  text(size: 8pt)[
    #table(
      columns: (0.7fr, 0.8fr, 0.8fr, 0.9fr, 0.9fr, 0.8fr),
      align: (center, right, right, right, right, right),
      stroke: 0.5pt,
      table.header([*eps*], [*Kluster*], [*Noise*], [*Silhouette*], [*Rand Index*], [*NMI*]),
      [0,40], [10], [171], [0,382], [0,622], [0,384],
    [0,50], [4], [69], [0,424], [0,853], [0,663],
    [0,52], [3], [60], [0,510], [0,877], [0,708],
    [0,54], [3], [48], [0,501], [0,894], [0,733],
    [0,55], [3], [46], [0,500], [0,896], [0,739],
    [0,56], [3], [44], [0,498], [0,900], [0,744],
    [0,58], [3], [39], [0,493], [0,902], [0,744],
    [0,60], [2], [33], [0,557], [0,799], [0,615],
    [0,80], [2], [5], [0,536], [0,821], [0,730],
    [1,00], [2], [1], [0,534], [0,825], [0,763],
    )
  ],
  caption: [Pengaruh nilai eps pada DBSCAN dengan min_samples 5]
)

Nilai `eps=0.55` dipilih untuk perbandingan utama karena menghasilkan tiga kluster dengan noise 46 titik (13,45\%) dan metrik eksternal yang lebih baik daripada `eps=0.5`. Pada nilai ini, Silhouette Score dihitung pada 296 titik non-noise dan bernilai 0,500. Rand Index dan NMI pada seluruh 342 titik, dengan noise sebagai label -1, bernilai 0,896 dan 0,739. Jika noise dikeluarkan, Rand Index dan NMI pada 296 titik meningkat menjadi 0,984 dan 0,948, tetapi angka tersebut tidak sepenuhnya sebanding karena 46 titik dibuang.

#figure(
  image("output/dbscan_eps_sweep.png", width: 100%),
  caption: [Jumlah kluster, jumlah noise, Silhouette, dan NMI terhadap eps. Garis putus-putus menandai eps 0,55 yang dipakai pada perbandingan utama.],
) <fig-dbscan-sweep>

== Gaussian Mixture Model

GMM memodelkan data sebagai campuran tiga distribusi Gaussian dengan full covariance. Setiap titik memiliki probabilitas keanggotaan pada setiap komponen, lalu label akhir diambil dari komponen dengan probabilitas tertinggi. Full covariance dipakai karena fitur-fitur penguin saling berkorelasi, misalnya `flipper_length_mm` dan `body_mass_g` memiliki korelasi 0,871.

#figure(
  image("output/gmm_species_heatmap.png", width: 62%),
  caption: [Jumlah spesies pada setiap kluster GMM. Kluster 0 berisi 123 Gentoo, kluster 1 berisi 149 Adelie dan 3 Chinstrap, dan kluster 2 berisi 2 Adelie dan 65 Chinstrap.],
) <fig-gmm>

GMM menghasilkan tiga kluster berukuran 123, 152, dan 67. Kluster 0 seluruhnya berisi Gentoo. Kluster 1 berisi 149 Adelie dan 3 Chinstrap, sedangkan kluster 2 berisi 2 Adelie dan 65 Chinstrap. Hanya lima penguin yang ditempatkan pada kluster yang tidak sesuai dengan spesies mayoritas. Silhouette Score-nya 0,455, Rand Index 0,982, dan NMI 0,935.

== Spectral Clustering

Spectral Clustering dijalankan dengan tiga kluster, `n_neighbors=10`, dan `assign_labels="kmeans"`. Algoritma ini membangun graf kemiripan antar titik, lalu mempartisi graf menggunakan vektor eigen dari matriks Laplacian. Hasilnya adalah kluster berukuran 176, 123, dan 43. Kluster 123 seluruhnya berisi Gentoo, kluster 176 berisi 151 Adelie dan 25 Chinstrap, dan kluster 43 berisi 43 Chinstrap. Silhouette Score-nya 0,462, Rand Index 0,917, dan NMI 0,831.

== Perbandingan Visual

Scatter plot berikut memakai `bill_length_mm` dan `flipper_length_mm` agar hasil mudah dibandingkan dengan scatter plot awal. Clustering tetap dijalankan pada empat fitur yang sudah distandardisasi, sehingga gambar ini adalah proyeksi dua dimensi. Label kluster bersifat arbitrer dan warna antar algoritma tidak saling berkorespondensi.

#figure(
  image("output/cluster_comparison.png", width: 100%),
  caption: [Hasil clustering pada proyeksi bill_length_mm terhadap flipper_length_mm. Titik hitam pada DBSCAN adalah noise.],
) <fig-clusters>

= Evaluasi Hasil Clustering

== Metrik Evaluasi

Silhouette Score mengukur kohesi dan pemisahan kluster tanpa memakai label spesies. Nilai mendekati 1 berarti titik-titik dalam satu kluster rapat dan jauh dari kluster lain. Rand Index mengukur proporsi pasangan titik yang pengelompokannya sama antara hasil clustering dan label spesies. NMI mengukur kesamaan informasi antara dua partisi. Untuk DBSCAN, Silhouette dihitung tanpa titik noise, sedangkan Rand Index dan NMI utama dihitung pada seluruh titik dengan noise sebagai label -1.

#figure(
  text(size: 8pt)[
    #table(
      columns: (2.3fr, 0.6fr, 0.6fr, 0.7fr, 0.8fr, 0.8fr, 0.7fr, 0.7fr),
      align: (left, right, right, right, right, right, right, right),
      stroke: 0.5pt,
      table.header([*Algoritma*], [*Kluster*], [*Noise*], [*n Sil*], [*Silhouette*], [*Rand Index*], [*NMI*], [*ARI*]),
      [Agglomerative (Ward)], [3], [0], [342], [0,454], [0,961], [0,901], [0,916],
    [DBSCAN (eps=0.55)], [3], [46], [296], [0,500], [0,896], [0,739], [0,765],
    [GMM (3 komponen)], [3], [0], [342], [0,455], [0,982], [0,935], [0,960],
    [Spectral (3 kluster)], [3], [0], [342], [0,462], [0,917], [0,831], [0,825],
    )
  ],
  caption: [Perbandingan metrik evaluasi keempat algoritma. n Sil adalah jumlah titik yang dipakai untuk menghitung Silhouette.]
)

== Perbandingan Algoritma

GMM memiliki Rand Index dan NMI tertinggi, yaitu 0,982 dan 0,935. Agglomerative Ward berada di posisi kedua dengan Rand Index 0,961 dan NMI 0,901. Spectral memiliki Silhouette tertinggi, 0,462, tetapi NMI-nya hanya 0,831 karena 25 Chinstrap bergabung dengan Adelie. DBSCAN memiliki Silhouette tertinggi di antara semua algoritma, 0,500, tetapi hanya dihitung pada 296 titik non-noise. Jika seluruh titik dihitung dengan noise sebagai label -1, NMI DBSCAN turun menjadi 0,739.

#figure(
  image("output/metrics_comparison.png", width: 100%),
  caption: [Perbandingan Silhouette Score, Rand Index, dan NMI untuk keempat algoritma.],
) <fig-metrics>

== Interpretasi Kluster GMM

GMM paling baik memisahkan Gentoo dari dua spesies lainnya. Kluster 0 berisi 123 Gentoo tanpa satu pun Adelie atau Chinstrap. Batas antara Adelie dan Chinstrap juga cukup tajam: hanya 3 Chinstrap yang masuk ke kluster Adelie dan 2 Adelie yang masuk ke kluster Chinstrap. Total kesalahan relatif terhadap spesies mayoritas adalah 5 dari 342 data, atau 1,46\%. Hasil ini konsisten dengan Rand Index 0,982 dan NMI 0,935.

= Uji Kestabilan

Uji kestabilan menjalankan ulang setiap algoritma pada 90% data yang diambil acak tanpa pengembalian, sebanyak tiga kali dengan seed 42, 43, dan 44. Hasil setiap sampel dibandingkan dengan hasil data penuh pada titik yang sama menggunakan Adjusted Rand Index (ARI) dan NMI. Nilai yang tinggi menunjukkan partisi yang konsisten terhadap perubahan kecil pada dataset.

#figure(
  text(size: 8pt)[
    #table(
      columns: (2.2fr, 1.2fr, 1.2fr, 1.2fr, 0.7fr, 0.7fr),
      align: (left, right, right, right, right, right),
      stroke: 0.5pt,
      table.header([*Algoritma*], [*ARI vs penuh*], [*NMI vs penuh*], [*Silhouette sampel*], [*Kluster*], [*Noise*]),
      [Agglomerative (Ward)], [0,741 ± 0,135], [0,798 ± 0,082], [0,436 ± 0,013], [3,0], [0,0],
    [DBSCAN (eps=0.55)], [0,949 ± 0,039], [0,926 ± 0,041], [0,458 ± 0,062], [3,7], [44,0],
    [GMM (3 komponen)], [0,988 ± 0,011], [0,980 ± 0,017], [0,454 ± 0,002], [3,0], [0,0],
    [Spectral (3 kluster)], [1,000 ± 0,000], [1,000 ± 0,000], [0,459 ± 0,001], [3,0], [0,0],
    )
  ],
  caption: [Rata-rata dan simpangan baku hasil uji kestabilan pada tiga sampel 90%]
)

#figure(
  image("output/stability_comparison.png", width: 96%),
  caption: [Kestabilan ARI dan NMI terhadap hasil data penuh. Error bar menunjukkan simpangan baku tiga sampel.],
) <fig-stability>

Spectral Clustering paling stabil dengan ARI dan NMI 1,000 pada ketiga sampel. GMM juga sangat stabil dengan ARI 0,988 dan NMI 0,980. DBSCAN memiliki ARI 0,949 dan NMI 0,926, tetapi jumlah klusternya berubah pada salah satu sampel sehingga rata-rata kluster menjadi 3,7. Agglomerative Ward paling tidak stabil dengan ARI 0,741 dan NMI 0,798, karena pemotongan dendrogram pada sampel yang berbeda dapat memindahkan beberapa titik batas antara Adelie dan Chinstrap.

= Kesimpulan

Empat algoritma clustering telah diterapkan pada 342 baris data penguin yang bersih dan distandardisasi. GMM dengan tiga komponen memberikan keseimbangan terbaik: Silhouette 0,455, Rand Index 0,982, NMI 0,935, dan ARI 0,960. GMM memisahkan Gentoo dengan sempurna dan hanya menempatkan lima penguin Adelie atau Chinstrap pada kluster yang salah. GMM juga stabil pada sampel 90% dengan ARI 0,988 dan NMI 0,980.

Agglomerative Ward juga kuat dengan Rand Index 0,961 dan NMI 0,901, tetapi kestabilannya lebih rendah, yaitu ARI 0,741. Spectral memiliki Silhouette tertinggi, 0,462, dan sangat stabil, tetapi NMI-nya hanya 0,831 karena batas Adelie dan Chinstrap kurang tepat. DBSCAN dengan `eps=0.55` menghasilkan Silhouette 0,500 pada 296 titik non-noise dan NMI 0,739 pada seluruh titik, tetapi membuang 46 titik sebagai noise.

Secara keseluruhan, GMM paling cocok untuk dataset ini karena memakai seluruh data, memisahkan Gentoo dengan sangat baik, memiliki metrik eksternal tertinggi, dan stabil pada sampel 90%. DBSCAN lebih cocok dipakai sebagai pendeteksi outlier atau titik batas, bukan sebagai pengganti clustering utama.

== Saran Pengembangan

+ Membandingkan GMM dengan variasi `covariance_type`, misalnya `tied` atau `diag`, untuk melihat apakah model yang lebih sederhana tetap akurat.
+ Menambahkan validasi silang dan bootstrap yang lebih banyak agar estimasi kestabilan tidak bergantung pada tiga sampel saja.
+ Menguji algoritma pada fitur rasio, misalnya rasio panjang dan kedalaman paruh, karena rasio dapat mengurangi pengaruh ukuran tubuh.
+ Menambahkan analisis jumlah kluster optimal dengan Silhouette, BIC, dan Davies-Bouldin sebelum memilih tiga kluster.
+ Memvalidasi hasil pada data penguin yang lebih baru atau populasi lain untuk melihat apakah struktur kluster bersifat umum.
