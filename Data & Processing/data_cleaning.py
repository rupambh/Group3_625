# remove the recipes that have less than 4 reviews
import sys


review_count = {}
filepath = sys.argv[1]
#filepath = '/Users/Sherry_Se7en/Downloads/food-com-recipes-and-user-interactions/RAW_interactions_100.csv'

with open(filepath, "r") as fp:
    lines = fp.readlines()
    for line in lines:
        if line[:1].isdigit():
            cut_line = line.split(',')
            if len(cut_line) == 5:
                if cut_line[1] in review_count:
                    review_count[cut_line[1]] += 1
                else:
                    review_count[cut_line[1]] = 1


for key, value in list(review_count.items()):
    if value < 5:
        review_count.pop(key)

filepath = sys.argv[2]
sig_keys = ",".join(list(review_count.keys()))
with open(filepath, "w+") as fp:
    fp.write(sig_keys)




            
