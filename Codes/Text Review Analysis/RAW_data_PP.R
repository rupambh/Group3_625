good_recipe_id = t(read.table("../output.txt", header = F, sep = ","))
colnames(good_recipe_id) = "recipe_id"
good_recipe_id = data.frame(good_recipe_id)
review_orig = read.csv("/Users/Sherry_Se7en/Downloads/food-com-recipes-and-user-interactions/RAW_interactions.csv", 
                       stringsAsFactors = F)
review_full = review_orig %>% select(user_id, recipe_id, rating, review)
#try_select = inner_join(review_100, good_recipe_id, by = "recipe_id")
select_good_recipe = inner_join(review_full, good_recipe_id, by = "recipe_id")

