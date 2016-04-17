import numpy as np
from sklearn.cluster import AffinityPropagation

all_urls = []
urls = dict()
idx_to_url = dict()
last_class = 0

def get_class_for_url(url):
    global urls, last_class

    if url not in all_urls:
        all_urls.append(url)
    
    if url not in urls:
        urls[url] = last_class
        last_class += 1

    return urls[url]

def answer_to_value(val):
    return 1 if val == "Yes" else 0


def record_in_matrix(class1, class2, answer):
    pass
    

def build_class_labels():
    with open("results") as f:
        for l in f:
            fields = l.split(",")
                        
            imgMain = get_class_for_url(fields[2])

            imgOne = get_class_for_url(fields[3])
            imgTwo = get_class_for_url(fields[6])
            imgThree = get_class_for_url(fields[9])
            imgFour = get_class_for_url(fields[12])


def record_in_matrix(m):
    def inc_sem(m, v1, v2, val):
        m[v1][v2] += val
        m[v2][v1] += val
    
    with open("results") as f:
        for l in f:
            fields = l.split(",")
            imgMain = get_class_for_url(fields[2])

            imgOne = get_class_for_url(fields[3])
            imgTwo = get_class_for_url(fields[6])
            imgThree = get_class_for_url(fields[9])
            imgFour = get_class_for_url(fields[12])

            ansOne   = answer_to_value(fields[4])
            ansTwo   = answer_to_value(fields[7])
            ansThree = answer_to_value(fields[10])
            ansFour  = answer_to_value(fields[13])


            inc_sem(m, imgMain, imgOne, ansOne)
            inc_sem(m, imgMain, imgTwo, ansTwo)
            inc_sem(m, imgMain, imgThree, ansThree)
            inc_sem(m, imgMain, imgFour, ansFour)
            

build_class_labels()
num_classes = len(urls)



sim_matrix = np.zeros((num_classes, num_classes))
record_in_matrix(sim_matrix)

np.savetxt("sim_mat.txt", sim_matrix)

clst = AffinityPropagation()
classes = clst.fit_predict(sim_matrix)


for idx, cls in enumerate(classes):
    print(all_urls[idx], cls)


