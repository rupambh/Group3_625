# use this script to transform tokens to numeric variable (counts of top words)
import sys
import csv
import copy


filepath_1 = './tfidf_words.csv'
filepath_2 = './review_full_tfidf.csv'
filepath_3 = './review_tfidf_as_variable_comma.csv'

word_count = {}

# input with the top 100 words and make a dict whose keys are those words
reader = csv.reader(open(filepath_1, 'r'))
wc_dict = {}
next(reader)
for row in reader:
    k, v = row
    wc_dict[k] = 0

# input with the tokens and count time when each words appears in each recipes' review
with open(filepath_2, "r") as fp:
    lines = fp.readlines()
    #print("bug here")
    for line in lines:
        if line[:1].isdigit():
            #line.replace('"', '')
            cut_line = line.replace('"', '').strip('\n').split(',')
            if cut_line[3] in wc_dict:
                if cut_line[1] in word_count:
                    #print(cut_line[1])
                    #print(cut_line[3])
                    word_count[cut_line[1]][cut_line[3]] += 1
                    #print(wc_dict[cut_line[3]])
                else:
                    word_count[cut_line[1]] = copy.deepcopy(wc_dict)
                    # wc_dict



 # write with numeric variable
   
with open(filepath_3, "w+") as fp:
    for key, value in word_count.items():
        word_count[key] = list(value.values())
        word_count[key] = ','.join(str(v) for v in word_count[key])
        fp.write("%s,%s\n"%(key, word_count[key]))