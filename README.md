# Project 2: Shiny App Development

### [Project Description](doc/project2_desc.md)

![screenshot](doc/figs/map.jpg)

In this second project of GR5243 Applied Data Science, we develop a *Exploratory Data Analysis and Visualization* shiny app on a topic of your choice using [JHU CSSE Covid-19 Data](https://github.com/CSSEGISandData/COVID-19) or NYC Health open data released on the [NYC Coronavirus Disease 2019 Data](https://github.com/nychealth/coronavirus-data) website. See [Project 2 Description](doc/project2_desc.md) for more details.  

The **learning goals** for this project is:

- business intelligence for data science
- study legacy codes and further development
- data cleaning
- data visualization
- systems development/design life cycle
- shiny app/shiny server

*The above general statement about project 2 can be removed once you are finished with your project. It is optional.

## NYC Outdoor Activities Guidebook
Term: Spring 2021

+ Team # Group 3
+ **Projec title**: + Team members
	+ team member 1: Ai, Haosheng
	+ team member 2: Chen, Ellen
	+ team member 3: Harris, Sean
	+ team member 4: He, Changhao
	+ team member 5: Pan, Yushi 

+ **Project summary**: Are you facing with the negative psychological effects of quarantine at home during the Covid? What about doing some outdoor activities! We provide a shiny dashborad of displaying places of NYC outdoor activities under the current pandemic. We hope outdoor activities could help you get rid of the post-traumatic stress symptoms! The interactive map page will give you distributions of activities in NYC. You can filter by choosing specific borough or zipcode to narrow your search. Since the pandemic does not end, we also provide time series trend plots for you to see the current and past confirmed cases and decide whether to go for the outdoor activities by yourself. Last but not least, we strongly recommend you to follow the New York City's Localized Restriction and Guidelines and do not forget to maintain at least 6ft social distancing while you are outside. 

+ **Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

**Haosheng Ai**:

**Ellen Chen**: Did data cleaning and manipulation for last7days-by-modzcta.csv, covid_cases_dataset.csv, zip_code_database.csv and group-cases-by-boro.csv; contributed to the global.R file

**Sean Harris**:

**Changhao He**: Extracted and cleaned caserate-by-modzcta.csv, percentpositive-by-modzcta.csv and now-cases-by-day.csv from the coronavirus-data github, then made the rate trend plot and case trend plot

**Yushi Pan**: Contributed outdoor activity part of the map, combined it with Haosheng's covid cases map. Contributed the global file, User Interface, Home and About page design. Helped organize the file and combine everyone's code chunks together. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

