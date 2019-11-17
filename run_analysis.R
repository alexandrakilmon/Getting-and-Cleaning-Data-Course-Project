# File capable of reading, merging, extracting, and labeling a revelent subset of data
# Assumes data is downloaded and extracted from zip file


# Loading training data

training = read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training[,562] = read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] = read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

# Loading testing data
testing = read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] = read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563] = read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

# Loading activity labels
activityLabels = read.csv("UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

# Loading features
features = read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])

# Merging the training and the test data
allData = rbind(training, testing)

# Extracting the mean and standard deviation for each measurement
cols <- grep(".*Mean.*|.*Std.*", features[,2])

# Naming the activities in the data set.

# Reducing the features
features <- features[cols,]

# Adding the last two columns
cols <- c(cols, 562, 563)

# Removing the unwanted columns 
allData <- allData[,cols]

# Adding features column
colnames(allData) <- c(features$V2, "Activity", "Subject")
colnames(allData) <- tolower(colnames(allData))

currentActivity = 1
for (currentActivityLabel in activityLabels$V2) {
  allData$activity <- gsub(currentActivity, currentActivityLabel, allData$activity)
  currentActivity <- currentActivity + 1
}

allData$activity <- as.factor(allData$activity)
allData$subject <- as.factor(allData$subject)

tidy_data = aggregate(allData, by=list(activity = allData$activity, subject=allData$subject), mean)

# Removing subject and activity columns
tidy_data[,90] = NULL
tidy_data[,89] = NULL

# Extracting tidy data
write.table(tidy_data, "tidy_data.txt", sep="\t", row.names=FALSE)