import numpy as np

BLOOM_FILTER = np.zeros((2^8))

def add(elem):
    for idx in range(7):
        hsh = md5(f"{idx}-{elem}".encode('utf-8')).hexdigest()
        pos = int(hsh[:2], 16)
        BLOOM_FILTER[idx][pos] =1

def find(elem):
    presence = []
    for idx in range(7):
        hsh = md5(f"{idx}-{elem}".encode('utf-8')).hexdigest()
        pos = int(hsh[:2], 16)
        presence.append(BLOOM_FILTER[pos])

    return all(presence)