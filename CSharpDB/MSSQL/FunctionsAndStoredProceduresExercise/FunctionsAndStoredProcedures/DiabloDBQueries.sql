USE Diablo

--13. *Cash in User Games Odd Rows
CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50))
RETURNS TABLE
AS
	RETURN (SELECT SUM(k.TotalCash) AS TotalCash
		  FROM (SELECT Cash AS TotalCash,
		  	ROW_NUMBER() OVER (ORDER BY Cash DESC) AS RowNumber
		  FROM Games AS g
		  JOIN UsersGames AS ug ON ug.GameId = g.Id
		  WHERE g.Name = @gameName) AS k
		WHERE k.RowNumber % 2 = 1)

SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')