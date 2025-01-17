# Viral Impact Predition on Tweets
# Author: Manuel de la Torre

# Load libraries
library("plspm")
library("plsdepot")
# library("devtools")
# install_github("vqv/ggbiplot")
# library("ggbiplot")

# Load data
setwd("/Users/manuelmhtr/Projects/Learning-R/ViralImpact");
list.files("./data")
tweetsRaw = read.csv("./data/tweetsSummary_v3.2withMozScore.csv")

# Filter useless data
tweets = subset(tweetsRaw, select=-c(id, userIdStr, twitterIdStr, messageHasMedia, messageIsDirect, postHourOfDay, postDayOfWeek))
# Normalizagin data (Inverting data where higher is worst)
tweets$userDefaultProfile      = 1 - tweets$userDefaultProfile
tweets$userDefaultProfileImage = 1 - tweets$userDefaultProfileImage
tweets$userTweetsPerDay        = tweets$userTweetsPerDay * -1
tweets$userStatusesCount       = tweets$userStatusesCount * -1
tweets$userFriendFollowRatio   = tweets$userFriendFollowRatio * -1
tweets$messageReach            = (tweetsRaw$messageIsDirect) * tweets$messageMentionsCount + (1 - tweetsRaw$messageIsDirect) * (tweets$userFollowersCount)
tweets$ctr                     = tweets$clicksCount / tweets$userFollowersCount 
head(tweets)
tweets[,1:4]
#plot(tweets[,1:4])

# Display data
head(tweets, n=6)
dim(tweets)
names(tweets)

# Basic plots
# Text length
boxplot(tweets$messageTextLength)
hist(tweets$messageTextLength)
# Number of words
boxplot(tweets$messageWordsCount)
hist(tweets$messageWordsCount)
# Number of clicks
boxplot(tweets$clicksCount)
hist(tweets$clicksCount)
# Followers count
boxplot(tweets$userFollowersCount)
hist(tweets$userFollowersCount)
# Followers count
boxplot(tweets$userFollowFriendRatio)
hist(tweets$userFollowFriendRatio)
# CTR
boxplot(tweets$clicksCount*100 / max(tweets$userFollowersCount,1))
hist(tweets$clicksCount*100 / tweets$userFollowersCount)


# CPA analysis
help(prcomp)
tweetsPca = prcomp(tweets[1:30], center = TRUE, scale. = TRUE) 
tweetsPca$rotation
tweetsRotationAbs = abs(tweetsPca$rotation)
tweetsRotationAbs
plot(tweetsPca, type = "l")
names(tweets)


# GET PRINCIPAL COMPONENTS:

# 1: userListedCount, userFollowersCount, messageReach
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC1"]),1]
userAudience_cols = c(15,17,30);
plot(nipals(tweets[,userAudience_cols]), main = "Audience indicators (circle of correlations)", cex.main = 1)

# 1.2: userMozScore, kloutScore
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC1"]),1]
userEngagement_cols = c(13,14,25);
plot(nipals(tweets[,userEngagement_cols]), main = "User Engagement indicators (circle of correlations)", cex.main = 1)

# 3: userTweetsPerDay, userStatusesCount, userAccountAge
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC4"]),4]
userActivity_cols = c(26,19,21);
plot(nipals(tweets[,userActivity_cols]), main = "User Activity indicators (circle of correlations)", cex.main = 1)

# 6: messageMediaCount, messageHashtagsCount
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC6"]),6]
messageContent_cols = c(12);
plot(nipals(tweets[,messageContent_cols]), main = "Message With Media indicators (circle of correlations)", cex.main = 1)

#################
### 1.2: userAccount Age, userVerified, userFollowFriendRatio
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC1"]),1]
userEngagement_cols = c(20,24,25);
plot(nipals(tweets[,userEngagement_cols]), main = "User Engagement indicators (circle of correlations)", cex.main = 1)

### 2: messageHasLocation, messageIsSensitive
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC2"]),2]
messageSensitive_cols = c(5,6);
plot(nipals(tweets[,messageSensitive_cols]), main = "Message Sensitive indicators (circle of correlations)", cex.main = 1)

### 3: userTweetsPerDay, userStatusesCount, userAccountAge
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC3"]),3]
userActivity_cols = c(26,19,21);
plot(nipals(tweets[,userActivity_cols]), main = "User Activity indicators (circle of correlations)", cex.main = 1)

# 4: messageTextLength, messageWordsCount
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC4"]),4]
messageExtension_cols = c(7, 8);
plot(nipals(tweets[,messageExtension_cols]), main = "Message Extension indicators (circle of correlations)", cex.main = 1)

# 5: /*userStatusesCount,*/ userHasLocation, userDescriptionLength
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC5"]),5]
userCommitment_cols = c(20, 18);
plot(nipals(tweets[,userCommitment_cols]), main = "User Commitment indicators (circle of correlations)", cex.main = 1)

# 7: userFavoritesCount, userFriendsCount
tweetsRotationAbs[order(-tweetsRotationAbs[,"PC7"]),7]
userInteraction_cols = c(17,15);
plot(nipals(tweets[,userInteraction_cols]), main = "User Interaction indicators (circle of correlations)", cex.main = 1)

# 8: messageIsDirect, messageMentionsCount
#tweetsRotationAbs[order(-tweetsRotationAbs[,"PC8"]),8]
#messageInteraction_cols = c(6,11);
#plot(nipals(tweets[,messageInteraction_cols]), main = "Message Interaction indicators (circle of correlations)", cex.main = 1)


# Othe components:
environment_cols   = c(29);
amplifyImpact_cols = c(1,4);
actionImpact_cols  = c(2:3);

# Build the model
#UserEngagement     = c(0, 0, 0, 0, 0, 0, 0, 0);
#UserInteraction    = c(0, 0, 0, 0, 0, 0, 0, 0);

MessageContent     = c(0, 0, 0, 0, 0, 0);
UserActivity       = c(0, 0, 0, 0, 0, 0);
UserEngagement     = c(0, 0, 0, 0, 0, 0);
UserAudience       = c(0, 0, 0, 0, 0, 0);
AmplifyImpact      = c(1, 1, 1, 1, 0, 0);
ActionImpact       = c(1, 1, 1, 1, 1, 0);



# Matrix created by row binding
tweetsInner = rbind(MessageContent, UserActivity, UserEngagement, UserAudience, AmplifyImpact, ActionImpact)
colnames(tweetsInner) = rownames(tweetsInner)

# plot the inner matrix
innerplot(tweetsInner)

# define list of indicators
tweetsOuter = list(messageContent_cols, userActivity_cols, userEngagement_cols, userAudience_cols, amplifyImpact_cols, actionImpact_cols)

# Tell variables are reflexive or formative
tweetsModes = rep("A", 6)

tweetsPls = plspm(tweets, tweetsInner, tweetsOuter, tweetsModes, maxiter=100)
# Goodness of fit (should be higher than 0.70)
tweetsPls$gof

# summarized results
summary(tweetsPls)

# Show results
tweetsPls$path_coefs
tweetsPls$inner_model
tweetsPls$inner_summary
plot(tweetsPls)
tweetsPls$crossloadings
plot(tweetsPls, what="loadings")
plot(tweetsPls, what="weights")


# Unidimensionallity
tweetsPls$unidim

#  Alphas must be higher than 0.7 to be acceotable (rule of thumb)
tweetsPls$unidim[, 3, drop = FALSE]

# Loadings and communalities
# communality must be higher than 0.7 (comes form 0.7^2 = 50% of variance)
tweetsPls$outer_model

# Cross loadings
# Does parameter is useful to describe blocks?
tweetsPls$crossloadings

# Explanation of the blocks
tweetsPls$inner_model
tweetsPls$inner_summary

# Validation
# Bootstraping: Add some noise to the original data to make sure that the model correctly
# describes data.
bootPls = plspm(analyzeData, tweetsInner, tweetsOuter, tweetsModes, boot.val = TRUE, br = 100)

# Bootstraping results
bootPls$boot



# principal components
tweetsPc = princomp(tweets);
summary(tweetsPc, loadings=TRUE)
help(princomp);

cor(tweets[c(3:10,20)])
# PCA of Influencer indicators with nipals
infleuncer_pca = nipals(tweets[,c(17:19,23,28:31)])
plot(infleuncer_pca, main = "Influencer indicators (circle of correlations)", cex.main = 1)
# PCA of Content indicators with nipals
content_pca = nipals(tweets[,7:11])
plot(content_pca, main = "Influencer indicators (circle of correlations)", cex.main = 1)




############

# Build the model
UserEngagement     = c(0, 0, 0, 0, 0, 0);
UserActivity       = c(0, 0, 0, 0, 0, 0);
UserInteraction    = c(0, 0, 0, 0, 0, 0);
MessagewithMedia   = c(0, 0, 0, 0, 0, 0);
UserAudience       = c(0, 0, 0, 0, 0, 0);
AmplifyImpact      = c(1, 1, 1, 1, 1, 0);

# Matrix created by row binding
tweetsInner = rbind(UserEngagement, UserActivity, UserInteraction, MessagewithMedia, UserAudience, AmplifyImpact)
colnames(tweetsInner) = rownames(tweetsInner)

tweetsOuter = list(userEngagement_cols, userActivity_cols, userInteraction_cols, messagewithMedia_cols, userAudience_cols, amplifyImpact_cols)

tweetsModes = rep("A", 6)

tweetsPls = plspm(tweets, tweetsInner, tweetsOuter, tweetsModes, maxiter=200)
tweetsPls$gof

# summarized results
summary(tweetsPls)

# Show results
tweetsPls$path_coefs
tweetsPls$inner_model
tweetsPls$inner_summary
plot(tweetsPls)
tweetsPls$crossloadings
plot(tweetsPls, what="loadings")
plot(tweetsPls, what="weights")