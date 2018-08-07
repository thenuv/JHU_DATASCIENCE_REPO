US Top 10 Universities 2018
========================================================
author: thenuv
date: August 7, 2018
autosize: true

Overview
========================================================
This presentation provides an overview of a simple application developed using **Shiny**.
The application is based on sample data for **Top 10 Universities in US for year 2018.**
The following are covered in this session:

- Structure of the Application
- How to Use
- Sample Data



Structure of the Application
========================================================

**Data Set**  
It's defined in the Server script with columns
- University Name
- Rank
- Latitude
- Longitude

**User Interface**  
There is one List in the side panel. The main panel displays University Rank, Name, Address 
and Map of the Location.

**Server Logic**  
Takes the Rank as input from UI. Returns the University Name, Rank, Address and the Map as output.
Address is derived with the latitude & longitude values in the data set using a function calling *Google api*.
The location is plot with *leaflet*.


How to Use
========================================================
**Side Panel**
- The user can select the desired Rank (1 -10) to view the details. 
- The default value is set to Rank 9.

**Main Panel**
- The main panel displays the details for the selected input. 
- University Name, Rank and Address are displayed as text.

**Map**
- The map points to the location of the University. 
- Its interactive and can be used as any other maps.
- The marker highlights the name as we hover/click it.


Sample Data
========================================================
**Data Set** 


```r
print(head(df_univ,4), row.names = FALSE) # Display the data set
```

```
 Rank                        UniversityName
    1 Massachusetts Institute of Technology
    2                   Stanford University
    3                    Harvard University
    4    California Institute of Technology
```

*Source: The data is referred from QS Top Universities Ranking*
https://www.topuniversities.com/university-rankings-articles/world-university-rankings/top-universities-us-2018
