Use PortfolioProject_MarketingAnalytics;

Select * 
From dbo.products

-- ****************************************

Select MAX(Price) as max_price,
	MIN(Price) as min_price
From
	dbo.products

-- Query to Categorize each product based on its price/

Select 
	ProductID,
	ProductName,
	Category,
	Price,
	CASE
		WHEN Price <= 50 THEN  'Low'
		WHEN Price BETWEEN 51 AND 200 THEN 'Medium'
		ELSE 'High'
	END AS PriceCategory
FROM 
	dbo.products;

--********************************

Select 
	* 
From 
	dbo.customers

Select 
	* 
From 
	geography

--***************************************

Select 
	c.CustomerID,
	c.CustomerName,
	c.Email,
	c.Gender,
	c.Age,
	g.Country,
	g.city
From 
	Customers c
LEFT JOIN 
	geography g
ON  c.GeographyID = g.GeographyID;


--*******************************
--Fact Table
Select * 
From 
	dbo.customer_reviews;

--************************************


-- Query to clean the Review Texts from double spacing to single. 

Select 
	ReviewID,
	CustomerID,
	ProductID,
	ReviewDate,
	Rating,
	
	REPLACE(ReviewText, '  ' , ' ') AS ReviewText

FROM	
	dbo.customer_reviews;

--**************************************************************

Select *
From 
	dbo.engagement_data

--*************************************************

--Query to clean the format of ContentType , Change date format of Eng date, Extract Views and Clicks in different cols.

Select 
	EngagementID,
	ContentID,
	Likes,
	CampaignID,
	ProductID,
	UPPER(REPLACE(ContentType, 'SocialMedia', 'Social Media')) as ContentType,
	LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) -  1) AS  Views,
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) -  CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
	FORMAT(CONVERT(DATE, EngagementDate), 'dd/mm/yyyy') AS EngagementDate 

From 
	dbo. engagement_data
Where
	ContentType !=  'Newsletter';

--******************************************************

Select *
From 
	dbo.customer_journey

--*********************************************************
-- Query to check if there are any duplicate records ; using row number to identify that

WITH DupRec AS (
Select 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	Duration,
	ROW_NUMBER() OVER (PARTITION BY  CustomerID, ProductID, VisitDate, Stage, Action ORDER BY  JourneyID) AS row_no
From 
	dbo.customer_journey
)
Select 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	Duration
FROM 
	DupRec
Where row_no > 1
Order  by JourneyID


-- Query to Retrive only clean and standard data. Only the rows that have row no as 1 bcause they are unique and no duplicate record will be returned.
-- Along with that we need to find average duration for the Null values. 


Select 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, avg_duration) as duration
From 
	( 
	 Select 
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		AVG(Duration) OVER(PARTITION by VisitDate) as avg_duration,
		ROW_NUMBER() OVER (PARTITION BY  CustomerID, ProductID, VisitDate, Stage, Action ORDER BY  JourneyID) AS row_no
	From 
		dbo.customer_journey

	) As sub_query
Where 
	row_no = 1



	SELECT @@SERVERNAME;
