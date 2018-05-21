# Math-189-Project

In our project, we will use data from the HMOG data set (http://www.cs.wm.edu/~qyang/hmog.html) to classify people's behavior on their smartphones. We will analyze data to arrive at a technique for determining which of three activities a standing phone user is doing: reading with their phone, navigating a map with their phone, or writing using the phone's keyboard.

# Data Organization within the folder 
The following description is from the dataset access at [link](http://www.cs.wm.edu/~qyang/hmog.html).
## Data Collection Tool
We developed a data collection tool for Android phones to record real-time touch, sensor and key press data invoked by user's interaction with the phone. Data from three usage scenarios on smartphones were recorded: (1) document reading; (2) text production; (3) navigation on a map to locate a destination.

## Data Collection Process
We recruited 100 volunteers for a large-scale data collection. When a volunteer logs into the data collection tool, s/he is randomly assigned a reading, writing, or map navigation session. For each session, the volunteer either sits or walks to finish the tasks. One session lasts about 5 to 15 minutes, and each volunteer is expected to perform 24 sessions (8 reading sessions, 8 writing sessions, and 8 map navigation sessions). In total, each volunteer in our experiments contributed about 2 to 6 hours of behavior traits.

## Dataset Content
The following 9 categories of data are recorded:
---
Accelerometer
Gyroscope
Magnetometer
Raw touch event
Tap gesture
Scale gesture
Scroll gesture
Fling gesture
Key press on virtual keyboard
---
The current dataset includes all the collected data from 100 volunteers. For each session, there are nine CSV files, each of which conresponds to one of the above data categories. There is another CSV file recording the meta-data of this session. The total size of this dataset is about 6GB after compression.
