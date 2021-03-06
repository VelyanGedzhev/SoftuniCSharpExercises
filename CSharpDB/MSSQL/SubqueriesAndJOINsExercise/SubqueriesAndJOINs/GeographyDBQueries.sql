USE Geography

--12. Highest Peaks in Bulgaria
SELECT 
		c.CountryCode,
		m.MountainRange,
		p.PeakName,
		p.Elevation
	FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
	JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
	JOIN Countries AS c ON c.CountryCode = mc.CountryCode
	WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
	ORDER BY p.Elevation DESC

--13. Count Mountain Ranges
SELECT
		c.CountryCode,
		COUNT(m.Id) AS MountainRanges
	FROM Countries AS c
	JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	JOIN Mountains AS m ON m.Id = mc.MountainId
	WHERE c.CountryCode IN ('BG', 'RU', 'US')
	GROUP BY c.CountryCode

--14. Countries with Rivers
SELECT TOP(5) 
		c.CountryName,
		r.RiverName
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
	LEFT JOIN Continents AS co ON co.ContinentCode = c.ContinentCode
	WHERE c.ContinentCode = 'AF' 
	ORDER BY c.CountryName

--15. *Continents and Currencies(not included in final score)

SELECT k.ContinentCode, k.CurrencyCode, k.CurrenyUsage FROM (
 SELECT 
 		c.ContinentCode,
 		c.CurrencyCode,
 		COUNT(c.CurrencyCode) AS CurrenyUsage,
		DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS Ranked
 	FROM Countries c
 	GROUP BY c.ContinentCode, c.CurrencyCode) AS k
	WHERE k.Ranked = 1 AND k.CurrenyUsage > 1
	ORDER BY k.ContinentCode

--16. Countries Without any Mountains
SELECT COUNT(c.CountryCode) AS [Count]
	FROM Countries as c
	LEFT JOIN MountainsCountries AS mr ON c.CountryCode = mr.CountryCode
	WHERE mr.CountryCode IS NULL

--17. Highest Peak and Longest River by Country
SELECT TOP(5) 
		c.CountryName,
		MAX(p.Elevation) AS HighestPeakElevation,
		MAX(r.Length) AS LongestRiverLength
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
	GROUP BY c.CountryName
	ORDER BY 
			HighestPeakElevation DESC, 
			LongestRiverLength DESC, 
			c.CountryName

--17. *Highest Peak Name and Elevation by Country(not included in final score)
SELECT TOP(5) 
		k.CountryName AS Country,
		k.[Highest Peak Name],
		k.[Highest Peak Elevation], Mountain
	FROM(
	SELECT  
		c.CountryName,
		ISNULL(p.PeakName, '(no highest peak)') AS [Highest Peak Name],
		ISNULL(MAX(p.Elevation), 0) AS [Highest Peak Elevation],
		DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY MAX(p.Elevation) DESC) AS Ranked,
		ISNULL(m.MountainRange, '(no mountain)') AS [Mountain]
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
	GROUP BY c.CountryName, p.PeakName, m.MountainRange
	) AS k
	WHERE k.Ranked = 1
	ORDER BY k.CountryName, k.[Highest Peak Name]