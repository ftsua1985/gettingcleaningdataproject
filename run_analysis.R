#assume already in working directory
library(plyr);

##set a file name for downloaded data
filename <- "usermovementdata.zip"

#download dataset
filelocation <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(filelocation, filename)
#unzip dataset
unzip(filename) 

#read data from the files
ActvityTestData  <- read.table('./test/y_test.txt',header = FALSE)
ActivityTrainData <- read.table('./train/y_train.txt',header = FALSE)

SubjectTrainData <- read.table('./train/subject_train.txt',header = FALSE)
SubjectTestData  <- read.table('./test/subject_test.txt',header = FALSE)

FeaturesTestData  <- read.table('./test/x_test.txt',header = FALSE)
FeaturesTrainData <- read.table('./train/x_train.txt',header = FALSE)

#join data tables by row
SubjectData <- rbind(SubjectTrainData, SubjectTestData)
ActivityData<- rbind(ActivityTrainData, ActvityTestData)
dataFeatures<- rbind(FeaturesTrainData, FeaturesTestData)

#assign variable names
names(SubjectData)<-c("subject")
names(ActivityData)<- c("activity")
dataFeaturesNames <- read.table('./features.txt',head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#combine columns to create a dataframe for all data
dataCombine <- cbind(SubjectData, ActivityData)
Data <- cbind(dataFeatures, dataCombine)

#subset feature names by measurements on mean/stddev
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#subset dataframe by chosen names of features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#read activity names from the labels file
activityLabels <- read.table('./activity_labels.txt',header = FALSE)

#relabel dataset with descriptive names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#output a tidy dataset
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)