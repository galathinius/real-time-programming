import numpy as np

CM_SKETCH = np.zeros((7, 16))

def cm_add(elem):
    for idx in range(7):
        hsh = md5(f"{idx}-{elem}".encode('utf-8')).hexdigest()
        pos = int(hsh[:1], 16)
        CM_SKETCH[idx][pos] +=1

def count(elem):
    counts = []
    for idx in range(7):
        hsh = md5(f"{idx}-{elem}".encode('utf-8')).hexdigest()
        pos = int(hsh[:1], 16)
        counts.append(CM_SKETCH[idx][pos])

    return min(counts)

