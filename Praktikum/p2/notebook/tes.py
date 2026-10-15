from __future__ import annotations

import sys
import math


def tokenize(line):
    """
    Pisahkan satu baris menjadi kata-kata lowercase.
    Baris kosong menjadi list kosong.
    """
    return line.split()


def build_tf(words):
    """
    Bangun dictionary term frequency.
    """
    tf = {}

    for word in words:
        tf[word] = tf.get(word, 0) + 1

    return tf


def magnitude(tf):
    """
    Hitung L2 norm dari vector term frequency.
    """
    return math.sqrt(sum(value * value for value in tf.values()))


def dot_product(tf_a, tf_b):
    """
    Hitung dot product antara dua vector TF.
    Dictionary yang lebih kecil digunakan untuk iterasi.
    """
    if len(tf_a) > len(tf_b):
        tf_a, tf_b = tf_b, tf_a

    total = 0

    for word, count in tf_a.items():
        if word in tf_b:
            total += count * tf_b[word]

    return total


def cosine_similarity(tf_q, tf_d):
    """
    Hitung cosine similarity query dan dokumen.
    """
    norm_q = magnitude(tf_q)
    norm_d = magnitude(tf_d)

    if norm_q == 0.0 or norm_d == 0.0:
        return 0.0

    return dot_product(tf_q, tf_d) / (norm_q * norm_d)


def main():
    data = sys.stdin.read().split("\n")

    if not data or not data[0].strip():
        return

    N, M = map(int, data[0].split())

    # Ambil tepat N baris sebagai dokumen.
    documents = data[1:1 + N]

    # Baris setelah seluruh dokumen merupakan query.
    query_line = data[1 + N] if 1 + N < len(data) else ""

    tf_query = build_tf(tokenize(query_line))
    norm_query = magnitude(tf_query)

    # Query kosong.
    if norm_query == 0.0:
        print(-1)
        return

    best_index = -1
    best_similarity = -1.0
    tolerance = 1e-9

    for index, document in enumerate(documents, start=1):
        tf_document = build_tf(tokenize(document))
        norm_document = magnitude(tf_document)

        # Dokumen kosong tidak dapat dibandingkan.
        if norm_document == 0.0:
            continue

        similarity = (
            dot_product(tf_query, tf_document)
            / (norm_query * norm_document)
        )

        # Update hanya jika nilainya benar-benar lebih besar.
        # Jika sama dalam toleransi 1e-9, index lama dipertahankan
        # karena iterasi dilakukan dari index terkecil.
        if (
            best_index == -1
            or similarity > best_similarity + tolerance
        ):
            best_index = index
            best_similarity = similarity

    # Berarti seluruh dokumen kosong.
    if best_index == -1:
        print(-1)
        return

    print(f"{best_index} {best_similarity:.6f}")


main()