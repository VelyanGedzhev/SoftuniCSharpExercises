USE Diablo

--Problem 14. Games from 2011 and 2012 year

SELECT TOP(50) [Name], FORMAT([Start], 'yyyy-MM-dd', 'en-US') AS [Start]
	FROM Games
	WHERE DATEPART(YEAR, [Start]) = 2011 OR DATEPART(YEAR, [Start]) = 2012
	ORDER BY
		[Start],
		[Name]

--Problem 15. User Email Providers

SELECT 
		Username, 
		RIGHT(Email, (LEN(Email) - CHARINDEX('@', Email))) AS EmailProvider
	FROM Users
	ORDER BY 
		EmailProvider,
		Username

--Problem 16. Get Users with IPAdress Like Pattern"***.1^.^.***". 

SELECT Username, IpAddress
	FROM Users
	WHERE IpAddress LIKE '___.1%.%.___'
	ORDER BY Username

--Problem 17. Show All Games with Duration and Part of the Day

SELECT 
	[Name],
	CASE
		WHEN DATEPART(HOUR, Start) BETWEEN 0 AND 11 THEN 'Morning'
		WHEN DATEPART(HOUR, Start) BETWEEN 12 AND 17 THEN 'Afternoon'
		WHEN DATEPART(HOUR, Start) BETWEEN 18 AND 23 THEN 'Evening'
	END
	AS [Part Of the Day],
	CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		ELSE'Extra Long'
	END
	AS [Duration]
FROM Games
ORDER BY 
	[Name],
	[Duration],
	[Part of the day]
