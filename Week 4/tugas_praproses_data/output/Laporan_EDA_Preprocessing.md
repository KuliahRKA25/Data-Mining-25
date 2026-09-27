# Laporan Komprehensif EDA dan Preprocessing
## House Prices Advanced Regression Techniques
### 5054251001 Benedictus Ryu Gunawan Tugas Praproses Data

Dataset: `train.csv` dari House Prices Advanced Regression Techniques.
Target: `SalePrice` (harga jual rumah dalam dolar).
Lingkup notebook: `5054251001_Benedictus Ryu Gunawan_Tugas_Praproses_Data.ipynb` dengan 43 sel, 1460 baris data.

Semua visualisasi di bawah berasal dari output notebook dan telah diekstrak ke folder `output/figures/`:
- `cell07_out1_fig0.png`: missingno bar
- `cell11_out2_fig1.png`: missingno heatmap dan matrix
- `cell17_out1_fig2.png`: histogram 37 kolom numerik
- `cell18_out0_fig3.png`: boxplot 37 kolom numerik
- `cell20_out1_fig4.png`: heatmap korelasi numerik
- `cell39_out1_fig5.png`: VIF per fitur skala log
- `cell39_out2_fig6.png`: Top 15 VIF skala linear
- `cell40_out1_fig7.png`: scree plot dan cumulative variance PCA
- `cell41_out1_fig8.png`: loadings heatmap dan biplot
- `cell42_out3_fig9.png`: scatter PC1 vs PC2 dan distribusi PC1

---

## 1. EDA atau Exploratory Data Analysis

### 1.1 Gambaran umum dataset
Dataframe awal berukuran 1460 baris x 80 kolom setelah kolom `Id` dijadikan index dan dihapus dari fitur. Artinya ada 79 kolom prediktor ditambah 1 target `SalePrice`.

Komposisi awal:
- Numerik: 37 kolom termasuk target. Daftarnya adalah `MSSubClass`, `LotFrontage`, `LotArea`, `OverallQual`, `OverallCond`, `YearBuilt`, `YearRemodAdd`, `MasVnrArea`, `BsmtFinSF1`, `BsmtFinSF2`, `BsmtUnfSF`, `TotalBsmtSF`, `1stFlrSF`, `2ndFlrSF`, `LowQualFinSF`, `GrLivArea`, `BsmtFullBath`, `BsmtHalfBath`, `FullBath`, `HalfBath`, `BedroomAbvGr`, `KitchenAbvGr`, `TotRmsAbvGrd`, `Fireplaces`, `GarageYrBlt`, `GarageCars`, `GarageArea`, `WoodDeckSF`, `OpenPorchSF`, `EnclosedPorch`, `3SsnPorch`, `ScreenPorch`, `PoolArea`, `MiscVal`, `MoSold`, `YrSold`, `SalePrice`.
- Kategoris atau object: 38 kolom setelah pembersihan awal. Contohnya `MSZoning`, `Street`, `LotShape`, `Neighborhood`, `HouseStyle`, `Foundation`, `Heating`, `CentralAir`, `KitchenQual`, `SaleType`, `SaleCondition`, dan lain lain.
- 5 kolom dengan missing ekstrem dihapus di tahap cleaning sehingga tersisa 75 kolom sebelum encoding. Rincian ada di Bagian 2.

Contoh 5 baris pertama menunjukkan pola umum Ames Housing:
- Id 1: RL, 65 ft frontage, 8450 sqft, OverallQual 7, YearBuilt 2003, SalePrice 208500.
- Id 2: RL, 80 ft frontage, 9600 sqft, OverallQual 6, YearBuilt 1976, SalePrice 181500.
- Id 4: OverallQual 7 tetapi YearBuilt 1915 dan SaleCondition Abnorml, SalePrice hanya 140000. Ini contoh interaksi umur dan kondisi terhadap harga.

### 1.2 Distribusi atribut numerik
Visualisasi: `cell17_out1_fig2.png` berisi 37 panel histogram plus KDE.

Temuan utama:
- `SalePrice` right skewed dengan skewness 1.88. Mayoritas di 120 ribu sampai 250 ribu, ekor panjang ke kanan sampai di atas 700 ribu. Ini konsisten dengan pasar rumah yang didominasi rumah menengah plus sedikit rumah mewah.
- Fitur luas seperti `LotArea`, `GrLivArea`, `TotalBsmtSF`, `1stFlrSF`, `MasVnrArea`, `WoodDeckSF`, `OpenPorchSF` juga right skewed. Contoh `LotArea` rentang 1300 sampai 215245, skewness awal 12.20.
- Fitur hitung yang jarang ada sangat zero inflated: `PoolArea`, `MiscVal`, `3SsnPorch`, `LowQualFinSF`, `BsmtFinSF2`, `ScreenPorch`, `EnclosedPorch`. Histogramnya menumpuk di nol dengan sedikit bar tinggi di kanan.
- Fitur tahun `YearBuilt`, `YearRemodAdd`, `GarageYrBlt` left skewed ringan dengan nilai negatif skew sekitar minus 0.50 sampai minus 0.67. Artinya banyak rumah relatif baru, sedikit rumah sangat tua.
- Fitur diskrit seperti `OverallQual`, `FullBath`, `BedroomAbvGr`, `Fireplaces`, `GarageCars` berbentuk ordinal dan mendekati simetris kecuali `KitchenAbvGr` yang skew 4.48 karena hampir semua rumah punya 1 dapur.

### 1.3 Korelasi awal dengan target
Visualisasi: `cell20_out1_fig4.png` heatmap korelasi 37 x 37 dengan anotasi dua desimal, cmap coolwarm.

Korelasi Pearson terhadap `SalePrice` dari notebook, urut menurun:
- Sangat kuat di atas 0.60: `OverallQual` 0.79, `GrLivArea` 0.70, `GarageCars` 0.64, `GarageArea` 0.62, `TotalBsmtSF` 0.61, `1stFlrSF` 0.60.
- Kuat 0.50 sampai 0.60: `FullBath` 0.56, `TotRmsAbvGrd` 0.53, `YearBuilt` 0.52, `YearRemodAdd` 0.50.
- Sedang 0.30 sampai 0.50: `MasVnrArea` 0.47, `Fireplaces` 0.46, `GarageYrBlt` 0.46, `BsmtFinSF1` 0.38, `LotFrontage` 0.33, `WoodDeckSF` 0.32, `2ndFlrSF` 0.31, `OpenPorchSF` 0.31.
- Lemah di bawah 0.30: `HalfBath` 0.28, `LotArea` 0.26, dan seterusnya.
- Mendekati nol atau negatif lemah: `MiscVal` minus 0.02, `LowQualFinSF` minus 0.02, `YrSold` minus 0.02, `OverallCond` minus 0.07, `MSSubClass` minus 0.08, `EnclosedPorch` minus 0.12, `KitchenAbvGr` minus 0.13.

Insight EDA: kualitas dan luas adalah driver harga. Korelasi bivariat tinggi ini menjadi dasar pemilihan fitur dan menjadi alasan mengapa kolinearitas di Bagian 5 harus ditangani serius.

### 1.4 Pola nilai hilang sebagai bagian EDA
Visualisasi: `cell07_out1_fig0.png` missingno bar dan `cell11_out2_fig1.png` missingno heatmap plus matrix.

Bar chart menunjukkan kelengkapan per kolom. Kolom paling kanan hampir kosong total untuk `PoolQC`, `MiscFeature`, `Alley`, `Fence`, `MasVnrType`. Heatmap korelasi missingness dan matrix menunjukkan missing terjadi bersamaan dalam blok. Contoh blok garasi dengan 81 baris hilang bersamaan untuk `GarageType`, `GarageYrBlt`, `GarageFinish`, `GarageQual`, `GarageCond`. Blok basement dengan 37 sampai 38 baris hilang bersamaan untuk `BsmtQual`, `BsmtCond`, `BsmtExposure`, `BsmtFinType1`, `BsmtFinType2`. Ini petunjuk kuat bahwa missing bukan acak melainkan struktural karena ketiadaan objek. Detail angka ada di Bagian 2.

---

## 2. Pembersihan Data

### 2.1 Periksa jumlah nilai hilang pada setiap atribut menggunakan pandas
Kode yang dipakai:
```python
missing_values = df.isnull().sum()
missing_percent = (missing_values / len(df)) * 100
missing_df = pd.DataFrame({"Missing Values": missing_values, "Percentage": missing_percent})
```

Hasil untuk 19 kolom yang punya missing, urut persentase menurun:
- `PoolQC`: 1453 atau 99.52 persen
- `MiscFeature`: 1406 atau 96.30 persen
- `Alley`: 1369 atau 93.76 persen
- `Fence`: 1179 atau 80.75 persen
- `MasVnrType`: 872 atau 59.72 persen
- `FireplaceQu`: 690 atau 47.26 persen
- `LotFrontage`: 259 atau 17.73 persen
- `GarageType`: 81 atau 5.54 persen
- `GarageYrBlt`: 81 atau 5.54 persen
- `GarageFinish`: 81 atau 5.54 persen
- `GarageQual`: 81 atau 5.54 persen
- `GarageCond`: 81 atau 5.54 persen
- `BsmtExposure`: 38 atau 2.60 persen
- `BsmtFinType2`: 38 atau 2.60 persen
- `BsmtQual`: 37 atau 2.53 persen
- `BsmtCond`: 37 atau 2.53 persen
- `BsmtFinType1`: 37 atau 2.53 persen
- `MasVnrArea`: 8 atau 0.54 persen
- `Electrical`: 1 atau 0.06 persen

Sisa 61 kolom tidak punya missing sama sekali termasuk target `SalePrice`.

### 2.2 Hapus kolom atau atribut dengan proporsi nilai hilang lebih dari 50 persen
Kode yang dipakai:
```python
cols_with_high_missing = missing_df[missing_df["Percentage"] > 50].index.tolist()
df.drop(columns=cols_with_high_missing, inplace=True)
```

Hasil: `['Alley', 'MasVnrType', 'PoolQC', 'Fence', 'MiscFeature']` sebanyak 5 kolom dihapus.

Alasan:
- Di atas 50 persen artinya mayoritas informasi hilang. Imputasi akan menciptakan data buatan yang mendominasi kolom dan menyesatkan model.
- Secara domain, 5 kolom ini menandakan fasilitas langka. Hanya 7 rumah punya data `PoolQC` dari 1460. Hanya 54 rumah punya data `MiscFeature`. Mempertahankannya hanya menambah noise dan dimensi tanpa daya prediksi yang stabil.
- Setelah penghapusan, dimensi menjadi 1460 x 75. Verifikasi dengan `df.isnull().sum()` menunjukkan tidak ada lagi kolom di atas 50 persen.

### 2.3 Tangani nilai hilang sisa
Sisa 14 kolom dengan missing di bawah 50 persen dibagi dua strategi berdasarkan tipe dan makna.

A. Kategoris diisi string `"None"` sebanyak 11 kolom:
```python
miss_cat_cols = ['BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2',
                 'BsmtQual', 'Electrical', 'GarageCond', 'GarageFinish',
                 'GarageQual', 'FireplaceQu', 'GarageType']
df[miss_cat_cols] = df[miss_cat_cols].fillna("None")
```
Rincian jumlahnya: `FireplaceQu` 690, `GarageType` dan kawan kawan garasi masing masing 81, `BsmtExposure` dan `BsmtFinType2` masing masing 38, `BsmtQual`, `BsmtCond`, `BsmtFinType1` masing masing 37, `Electrical` 1.

Alasan memakai `"None"` bukan modus:
- Missing di sini berarti tidak ada objek. Rumah tanpa perapian memang tidak punya `FireplaceQu`. Rumah tanpa garasi memang tidak punya `GarageType`. Rumah tanpa basement memang tidak punya `BsmtQual`. Mengisi dengan modus seperti `TA` atau `Attchd` akan salah secara faktual karena mengklaim ada kualitas padahal objeknya tidak ada.
- `"None"` menjadi kategori baru yang informatif bagi model. Model bisa belajar bahwa `FireplaceQu_None` berkaitan dengan harga lebih rendah dibanding `FireplaceQu_Gd`.
- Untuk `Electrical` yang hanya 1 hilang, `"None"` tetap konsisten dan tidak merusak distribusi karena hanya 0.06 persen.

B. Numerik diisi median sebanyak 3 kolom:
```python
miss_num_cols = ["MasVnrArea", "GarageYrBlt", "LotFrontage"]
df[miss_num_cols] = df[miss_num_cols].fillna(df[miss_num_cols].median())
```
Rincian: `LotFrontage` 259, `MasVnrArea` 8, `GarageYrBlt` 81.

Alasan memakai median bukan mean:
- `LotFrontage` skew 2.40 dan `MasVnrArea` skew 2.67. Mean akan tertarik oleh outlier kanan. Median robust dan menjaga pusat distribusi.
- `GarageYrBlt` berkaitan dengan tahun. Median tahun lebih stabil dibanding mean yang bisa menghasilkan tahun pecahan yang tidak realistis sebelum pembulatan.
- Setelah langkah ini, `df.isnull().sum().sort_values(ascending=False)` menunjukkan semua nol. Data bersih total dari missing.

Visualisasi pendukung `cell11_out2_fig1.png` memperkuat keputusan ini karena heatmap menunjukkan korelasi missing mendekati 1 di dalam blok garasi dan blok basement. Artinya imputasi blok harus konsisten satu paket, dan pendekatan `"None"` menjaga konsistensi paket tersebut.

---

## 3. Deteksi dan Penanganan Outlier

### 3.1 Gunakan boxplot untuk mendeteksi outlier pada atribut numerik
Kode yang dipakai:
```python
num_cols = df.select_dtypes(include=[int, float]).columns.tolist()
```
Didapat 37 kolom numerik termasuk target.

Dua visualisasi besar ukuran 30 x 50 inci:
- `cell17_out1_fig2.png`: histogram plus KDE per kolom untuk melihat bentuk, skew, dan zero inflation.
- `cell18_out0_fig3.png`: boxplot per kolom dengan `ax.boxplot(df[col])` untuk melihat median, IQR, whisker, dan titik di luar whisker sebagai kandidat outlier.

Temuan boxplot:
- `SalePrice` sendiri punya titik jauh di kanan atas di atas 600 ribu. Ini menjadi acuan penting.
- `LotArea` punya satu titik ekstrem 215245 sqft yang jauh dari box utama yang umumnya di bawah 15000.
- `MiscVal` punya titik sampai 15500 padahal median nol.
- `PoolArea` sampai 738, `3SsnPorch` sampai 508, `LowQualFinSF` sampai 572, `ScreenPorch` sampai 480, `EnclosedPorch` sampai 552, `BsmtFinSF2` sampai 1474.
- `GrLivArea`, `TotalBsmtSF`, `1stFlrSF`, `GarageArea`, `MasVnrArea` punya ekor kanan moderat.
- `OverallQual`, `OverallCond`, `FullBath`, `BedroomAbvGr` hampir tidak punya outlier ekstrem karena sifat ordinal terbatas.

### 3.2 Tentukan apakah outlier dihapus atau disesuaikan, dan jelaskan alasannya
Keputusan di notebook: outlier tidak dihapus barisnya, tetapi disesuaikan dengan clipping plus transformasi log. Alasannya:

1. Domain knowledge rumah mewah. Pola outlier di fitur luas dan kualitas mengikuti pola outlier di boxplot `SalePrice`. Rumah dengan `GrLivArea` sangat besar atau `OverallQual` 10 memang wajar berharga sangat tinggi. Menghapusnya berarti membuang segmen pasar mewah yang justru penting diprediksi.
2. Jumlah outlier tidak dominan tetapi informatif. Jika dihapus dengan aturan IQR kaku, banyak rumah unik hilang dan model menjadi bias ke rumah menengah saja.
3. Korelasi versus skewness menunjukkan outlier bukan sinyal kuat. Tabel `skew_with_corr` menunjukkan fitur dengan skew di atas 3 justru korelasinya rendah dengan target. Contoh `MiscVal` skew 24.47 tetapi korelasi minus 0.02. `PoolArea` skew 14.82 tetapi korelasi 0.09. `LotArea` skew 12.20 tetapi korelasi 0.26. Artinya nilai ekstrem ini lebih bersifat noise berekor panjang daripada pembeda harga utama. Karena itu tepat untuk dijinakkan, bukan dihapus.
4. Menjaga ukuran sampel 1460. Regresi dan PCA butuh sampel penuh agar varians stabil.

### 3.3 Penanganan konkret: clip kuantil 1 persen dan 99 persen plus log1p
Kode yang dipakai:
```python
cols_with_high_skewness = skew_with_corr[skew_with_corr['Skewness'].abs() > 3].index.tolist()
# 10 kolom: 3SsnPorch, BsmtFinSF2, BsmtHalfBath, EnclosedPorch, KitchenAbvGr,
# LotArea, LowQualFinSF, MiscVal, PoolArea, ScreenPorch
df[cols_with_high_skewness].clip(
  lower=df[cols_with_high_skewness].quantile(0.01),
  upper=df[cols_with_high_skewness].quantile(0.99),
  inplace=True, axis=1)
df[cols_with_high_skewness] = np.log1p(df[cols_with_high_skewness])
```

Rentang sebelum transformasi:
- `3SsnPorch`: 0 sampai 508
- `BsmtFinSF2`: 0 sampai 1474
- `BsmtHalfBath`: 0 sampai 2
- `EnclosedPorch`: 0 sampai 552
- `KitchenAbvGr`: 0 sampai 3
- `LotArea`: 1300 sampai 215245
- `LowQualFinSF`: 0 sampai 572
- `MiscVal`: 0 sampai 15500
- `PoolArea`: 0 sampai 738
- `ScreenPorch`: 0 sampai 480
Tidak ada nilai minus sehingga `log1p` cukup tanpa Yeo Johnson.

Hasil skew sesudah versus sebelum untuk kolom yang sama:
- `LotArea`: 12.20 menjadi minus 0.13. Perbaikan sangat baik, kini mendekati simetris.
- `EnclosedPorch`: 3.08 menjadi 2.11. Membaik.
- `BsmtFinSF2`: 4.25 menjadi 2.52. Membaik.
- `MiscVal`: 24.47 menjadi 5.17. Turun besar tetapi masih tinggi karena zero inflation ekstrem.
- `PoolArea`: 14.82 menjadi 14.36. Hampir tidak berubah karena terlalu banyak nol.
- `3SsnPorch`: 10.30 menjadi 7.73. Masih tinggi.
- `LowQualFinSF`: 9.01 menjadi 7.46. Masih tinggi.
- `ScreenPorch`: 4.12 menjadi 3.15. Sedikit membaik.
- `BsmtHalfBath`: 4.10 menjadi 3.93. Hampir tetap karena hanya 0, 1, 2.
- `KitchenAbvGr`: 4.48 menjadi 3.86. Hampir tetap karena diskrit 0 sampai 3.

Kesimpulan penanganan: cukup oke tetapi belum sempurna. Clip menahan ekstrem absolut, log1p memampatkan ekor kanan. Untuk kolom yang zero inflated parah, skew tetap tinggi karena masalahnya bukan outlier tunggal melainkan distribusi menumpuk di nol. Itu wajar dan tidak perlu dipaksa normal karena model tree based atau regresi dengan regularisasi masih bisa menanganinya. Notebook mencatat hal ini dengan tepat sebagai sudah cukup oke meski masih high skewness.

---

## 4. Transformasi Data

### 4.1 Lakukan normalisasi atau standarisasi atribut
Kode yang dipakai:
```python
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
scaled_features = scaler.fit_transform(df[num_cols])
scaled_df = pd.DataFrame(scaled_features, columns=num_cols, index=df.index)
df = pd.concat([scaled_df, df.drop(columns=num_cols)], axis=1)
```

Yang distandarisasi: seluruh 37 kolom numerik termasuk `SalePrice` dengan rumus z score yaitu x minus mean dibagi std sehingga mean 0 dan std 1.

Contoh hasil 5 baris pertama setelah scaling:
- Id 1: `MSSubClass` 0.07, `LotFrontage` minus 0.22, `LotArea` minus 0.13, `OverallQual` 0.65, `YearBuilt` 1.05, `YearRemodAdd` 0.87.
- Id 2: `MSSubClass` minus 0.87, `LotFrontage` 0.46, `OverallCond` 2.17, `YearBuilt` 0.15.
- Id 4 dengan rumah tua: `YearBuilt` minus 1.86.

Alasan memakai StandardScaler bukan MinMax:
- Banyak fitur beda skala ekstrem. `LotArea` ribuan sampai ratusan ribu, `OverallQual` hanya 1 sampai 10. Tanpa scaling, PCA dan regresi akan didominasi `LotArea` dan `GrLivArea`.
- StandardScaler menjaga outlier yang sudah dijinakkan tetap proporsional dalam satuan std, cocok untuk asumsi regresi dan jarak.
- Catatan kritis: menstandarisasi target `SalePrice` juga berarti interpretasi harga menjadi dalam satuan std. Untuk evaluasi akhir dalam dolar, perlu inverse transform. Notebook melakukan ini sebagai bagian preprocessing murni, dan itu sah selama konsisten antara train dan test.

### 4.2 Lakukan encoding atribut kategoris menggunakan one hot encoding
Langkah pertama adalah cek kardinalitas:
```python
cat_cols = df.select_dtypes(include=[object]).columns.tolist()
cardinality = df[cat_cols].nunique().sort_values(ascending=False)
```

Hasil 38 kolom kategoris:
- Kardinalitas tinggi di atas 10: `Neighborhood` 25, `Exterior2nd` 16, `Exterior1st` 15.
- Kardinalitas rendah 10 atau kurang sebanyak 35 kolom. Contoh `Condition1` 9, `SaleType` 9, `RoofMatl` 8, `Condition2` 8, `HouseStyle` 8, `BsmtFinType2` 7, `Functional` 7, `BsmtFinType1` 7, `GarageType` 7, `Foundation` 6, `Electrical` 6 termasuk level `None` baru, `SaleCondition` 6, `FireplaceQu` 6 termasuk `None`, dan seterusnya sampai `CentralAir` 2, `Utilities` 2, `Street` 2.

Strategi ganda yang dipakai notebook:

A. One hot encoding dengan drop first untuk 35 kolom kardinalitas rendah:
```python
df = pd.concat([df.drop(columns=cat_cols_with_low_cardinality),
                pd.get_dummies(df[cat_cols_with_low_cardinality], drop_first=True)], axis=1)
```
Alasan:
- Sesuai permintaan outline yaitu one hot encoding.
- `drop_first=True` menghindari dummy variable trap atau kolinearitas sempurna antar dummy. Contoh `Street_Pave`, `CentralAir_Y`, `Utilities_NoSeWa`, `PavedDrive_P`, `PavedDrive_Y`, `LandSlope_Mod`, `LandSlope_Sev`, `GarageFinish_None`, `GarageFinish_RFn`, `GarageFinish_Unf` terlihat di output sebagai kolom boolean.
- Untuk kolom rendah kardinalitas, ledakan dimensi masih terkendali.

B. Target encoding untuk 3 kolom kardinalitas tinggi:
```python
from category_encoders import TargetEncoder
te = TargetEncoder()
encoded = te.fit_transform(df[cat_cols_with_high_cardinality], df[TARGET])
```
Alasan:
- Jika `Neighborhood` dengan 25 nilai di one hot kan penuh, akan menambah 24 dummy yang jarang dan berisiko overfit. Target encoding mengganti tiap kategori dengan rata rata target yang dihaluskan sehingga hanya 1 kolom per fitur.
- Sama untuk `Exterior1st` 15 dan `Exterior2nd` 16 yang juga tinggi.
- Hasil akhir shape menjadi 1460 x 195. Artinya dari 75 kolom menjadi 195 kolom setelah ekspansi dummy plus target encoding. Ini disimpan ke `5054251001_Benedictus Ryu Gunawan_Tugas_Praproses_Data.csv`.

Kombinasi ini seimbang antara memenuhi outline dan menjaga praktik terbaik untuk kardinalitas tinggi.

---

## 5. Reduksi Dimensi

### 5.1 Gunakan analisis korelasi untuk mengidentifikasi atribut yang sangat berkorelasi, lalu buang salah satunya jika perlu
Visualisasi utama tetap `cell20_out1_fig4.png` plus tabel korelasi dengan target di Bagian 1.3.

Pasangan yang sangat berkorelasi secara konseptual dan empiris:
- `GarageCars` dan `GarageArea` dengan korelasi masing masing 0.64 dan 0.62 ke target dan saling berkorelasi tinggi satu sama lain karena kapasitas mobil menentukan luas.
- `1stFlrSF`, `2ndFlrSF`, `GrLivArea`, `TotalBsmtSF` saling terkait karena total luas hunian adalah penjumlahan komponen lantai dan basement.
- `TotRmsAbvGrd`, `BedroomAbvGr`, `FullBath`, `HalfBath` saling terkait karena jumlah kamar menentukan jumlah ruangan.
- `YearBuilt`, `YearRemodAdd`, `GarageYrBlt` saling terkait karena umur bangunan.
- `Exterior1st` dan `Exterior2nd` setelah target encoding juga berkorelasi karena material kedua sering mengikuti material pertama.

Notebook tidak membuang salah satu secara manual dengan threshold korelasi 0.90 misalnya, melainkan memakai pendekatan VIF plus PCA yang lebih sistematis. Alasannya:
- Membuang manual berisiko membuang informasi yang masih unik. Contoh `1stFlrSF` dan `2ndFlrSF` memang berkorelasi dengan `GrLivArea` tetapi distribusi lantai satu versus dua punya makna arsitektural berbeda.
- VIF mengukur multikolinearitas multivariat, bukan hanya pasangan, sehingga lebih tepat untuk regresi.

### 5.2 Gunakan VIF untuk konfirmasi multikolinearitas
Rumus yang dipakai di markdown notebook:
VIFj sama dengan 1 dibagi 1 minus Rj kuadrat, di mana Rj kuadrat adalah R squared dari regresi fitur j terhadap semua fitur lain. VIF 1 berarti tidak ada kolinearitas, VIF di atas 10 berarti high VIF.

Kode yang dipakai:
```python
from statsmodels.stats.outliers_influence import variance_inflation_factor
X = df.drop(columns=[TARGET]).select_dtypes(include=np.number)
```

Hasil VIF urut menurun untuk fitur numerik:
- `GrLivArea` 1059.50
- `2ndFlrSF` 730.82
- `1stFlrSF` 573.70
- `TotalBsmtSF` 36.87
- `BsmtFinSF1` 35.99
- `BsmtUnfSF` 35.27
- `Exterior2nd` 11.08
- `Exterior1st` 10.42
- Berikutnya `LowQualFinSF` 8.97, `YearBuilt` 5.65, `GarageCars` 5.60, `GarageArea` 5.51, dan seterusnya sampai `3SsnPorch` 1.03 yang hampir independen.

Dengan threshold lebih dari 10, didapat 8 fitur high VIF:
`['GrLivArea', '2ndFlrSF', '1stFlrSF', 'TotalBsmtSF', 'BsmtFinSF1', 'BsmtUnfSF', 'Exterior1st', 'Exterior2nd']`.

Visualisasi:
- `cell39_out1_fig5.png`: bar horizontal VIF per fitur skala log dengan garis merah di 10 dan oranye di 5. Skala log penting karena rentang 1 sampai lebih dari 1000.
- `cell39_out2_fig6.png`: Top 15 VIF skala linear dengan label angka 1059.5, 730.8, 573.7 yang menunjukkan dominasi tiga fitur luas.

Koreksi penting: teks markdown sel PCA sempat menyebut 21 fitur high VIF, tetapi output kode yang sah menunjukkan 8 fitur. Laporan ini memakai angka 8 yang terbukti dari tabel dan plot. Nilai ekstrem di atas 500 menandakan kolinearitas nyaris sempurna sehingga regresi linear tanpa penanganan akan tidak stabil dengan koefisien membengkak.

### 5.3 Gunakan PCA untuk mengurangi dimensi data
Alur PCA di notebook mengikuti rumus Z sama dengan X scaled dikali W, di mana X scaled adalah matriks high VIF yang sudah distandarisasi dan W adalah matriks loading eigenvektor. Tujuannya mengubah 8 fitur berkorelasi menjadi komponen ortogonal yang tidak berkorelasi.

Tahap 1: Standardisasi 8 fitur high VIF wajib karena PCA sensitif skala. `LotArea` ribuan versus `OverallQual` 1 sampai 10 adalah contoh mengapa tanpa scaling PC1 akan didominasi fitur besar saja.

Tahap 2: Fit PCA penuh dan lihat scree plot. Visualisasi `cell40_out1_fig7.png` berisi scree plot variance per PC dan kurva cumulative variance dengan garis 80 persen, 90 persen, 95 persen.

Tabel explained variance:
- PC1 36.82 persen, kumulatif 36.82 persen
- PC2 22.79 persen, kumulatif 59.61 persen
- PC3 18.97 persen, kumulatif 78.58 persen
- PC4 17.04 persen, kumulatif 95.62 persen
- PC5 3.17 persen, kumulatif 98.80 persen
- PC6 0.66 persen, kumulatif 99.45 persen
- PC7 0.50 persen, kumulatif 99.95 persen
- PC8 0.05 persen, kumulatif 100 persen

Kebutuhan komponen untuk ambang:
- Lebih dari sama dengan 80 persen: 4 PC dengan aktual 95.62 persen
- Lebih dari sama dengan 90 persen: 4 PC dengan aktual 95.62 persen
- Lebih dari sama dengan 95 persen: 4 PC dengan aktual 95.62 persen
Maka dipilih k sama dengan 4. Ini memampatkan 8 fitur menjadi 4 dengan retensi 95.62 persen, hemat 50 persen dimensi untuk blok kolinear.

Tahap 3: Interpretasi loadings dan biplot. Visualisasi `cell41_out1_fig8.png` berisi heatmap loadings PC1 sampai PC6 plus biplot PC1 vs PC2 dengan warna `SalePrice` dan 8 vektor fitur.

Loadings 6 PC pertama:
- PC1 didominasi `TotalBsmtSF` 0.494, `1stFlrSF` 0.474, `GrLivArea` 0.401, `Exterior1st` 0.354, `Exterior2nd` 0.349. Artinya PC1 adalah faktor ukuran total plus material eksterior. Kontributor absolut terbesar PC1 sesuai output adalah urutan tersebut.
- PC2 memisahkan basement finish versus lantai atas. `BsmtFinSF1` 0.495 positif, `Exterior2nd` minus 0.419, `Exterior1st` minus 0.411, `2ndFlrSF` minus 0.383.
- PC3 didominasi `2ndFlrSF` 0.635 dan `GrLivArea` 0.568, yaitu faktor lantai dua.
- PC4 didominasi `BsmtUnfSF` 0.693 dan `BsmtFinSF1` minus 0.498, yaitu kontras basement unfinished versus finished.

Biplot menunjukkan sebaran PC1 vs PC2 diwarnai `SalePrice` dengan gradasi viridis. Rumah mahal cenderung ke arah vektor `TotalBsmtSF`, `1stFlrSF`, `GrLivArea`, mengonfirmasi PC1 sebagai proksi kemewahan ukuran.

Tahap 4: Gabung kembali dan validasi. Kode:
```python
pca_opt = PCA(n_components=4, random_state=3407)
df_combined shape: 1460 x 191, dari 195 kolom menjadi 191 kolom karena 8 kolom high VIF diganti 4 kolom PC1 sampai PC4.
Kolom PC baru: PC1, PC2, PC3, PC4.
```

Visualisasi `cell42_out3_fig9.png` berisi scatter PC1 vs PC2 berwarna `SalePrice` plus histogram PC1 dengan KDE yang mendekati simetris.

Validasi sukses:
- VIF sesudah PCA semuanya 1.0 untuk PC1 sampai PC4.
- Korelasi antar PC mendekati 0. Matriks korelasi menunjukkan 1.0 di diagonal dan minus 0.0 atau 0.0 di luar diagonal.
- Artinya tujuan reduksi tercapai. Kolinearitas hilang, dimensi berkurang, informasi 95.62 persen tetap terjaga, kolom low VIF plus hasil encoding plus `SalePrice` tetap dipertahankan untuk modeling.

---

## Ringkasan Alur Preprocessing

1. Muat 1460 x 80, set `Id` sebagai index.
2. Audit missing dengan `isnull`, `missingno.bar`, `heatmap`, `matrix`. Hapus 5 kolom di atas 50 persen menjadi 1460 x 75.
3. Imputasi `"None"` untuk 11 kategoris struktural dan median untuk 3 numerik. Missing menjadi nol.
4. EDA distribusi dan boxplot 37 numerik. Tidak hapus baris outlier karena alasan rumah mewah. Lakukan clip 1 persen dan 99 persen plus `log1p` untuk 10 kolom skew di atas 3.
5. Standardisasi 37 numerik dengan StandardScaler. One hot `drop_first` untuk 35 kategoris rendah kardinalitas dan target encoding untuk 3 kategoris tinggi. Hasil 1460 x 195 dan disimpan ke CSV.
6. Analisis korelasi dan VIF menemukan 8 high VIF. PCA 8 menjadi 4 PC dengan 95.62 persen variance. Gabungan akhir 1460 x 191 dengan VIF 1.0 dan korelasi antar PC nol.

File akhir yang dihasilkan notebook adalah `5054251001_Benedictus Ryu Gunawan_Tugas_Praproses_Data.csv` untuk tahap preprocessing, sedangkan `df_combined` dengan PCA adalah artefak analisis reduksi dimensi.
