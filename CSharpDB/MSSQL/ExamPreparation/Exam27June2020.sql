--Section 1. DDL
CREATE DATABASE WMS
USE WMS

CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) CHECK(LEN(Phone) = 12) NOT NULL
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN('Pending', 'In Progress', 'Finished')) NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId)  NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0  NOT NULL
)

CREATE TABLE Vendors
(
	VendorId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	Price DECIMAL(15,2) CHECK(Price BETWEEN 1 AND 9999.99) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId)  NOT NULL,
	StockQty INT DEFAULT 0 CHECK(StockQty >= 0),
)

CREATE TABLE OrderParts
(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderID)  NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId)  NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity > 0)  NOT NULL,
	CONSTRAINT PK_OrdersParts PRIMARY KEY (OrderId, PartId)
)

CREATE TABLE PartsNeeded
(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId)  NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId)  NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity > 0)  NOT NULL,
	CONSTRAINT PK_JobsParts PRIMARY KEY (JobId, PartId)
)

--2. Insert
INSERT INTO Clients (FirstName, LastName, Phone) VALUES
('Teri',	'Ennaco', '570-889-5187'),
('Merlyn',	'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie',	'Mconnell',	'908-802-3564'),
('Lemuel',	'Latzke', '631-748-6479'),
('Melodie',	'Knipp', '805-690-1682'),
('Candida',	'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price, VendorId) VALUES
('WP8182119',	'Door Boot Seal', 117.86,	2),
('W10780048',	'Suspension Rod', 42.81,	1),
('W10841140',	'Silicone Adhesive',  6.77,	4),
('WPY055980',	'High Temperature Adhesive', 13.94,	3)

--3.Update
UPDATE Jobs
SET 
	MechanicId = 3,
	Status = 'In Progress'
WHERE Status = 'Pending'

--4.Delete
DELETE FROM OrderParts WHERE OrderId = 19
DELETE FROm Orders WHERE OrderId = 19

--5. Mechanic Assignments
SELECT 
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	j.Status,
	j.IssueDate
	FROM Mechanics AS m
	LEFT JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	ORDER BY m.MechanicId, j.IssueDate, j.JobId

--6.Current Clients
SELECT 
		CONCAT(c.FirstName, ' ', c.LastName) AS Client,
		DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going],
		j.Status
	FROM Clients AS c
	LEFT JOIN Jobs AS j ON j.ClientId = c.ClientId
	WHERE j.Status != 'Finished' -- OR [WHERE j.FinishDate IS NULL]
	ORDER BY [Days going] DESC

--7.Mechanic Performance
SELECT 
		CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
	FROM Mechanics AS m
	JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	GROUP BY j.MechanicId, CONCAT(m.FirstName, ' ', m.LastName)
	ORDER BY j.MechanicId 

--8.Available Mechanics
SELECT
		m.FirstName + ' ' +  m.LastName AS Mechanic
	FROM Mechanics AS m
	LEFT JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	WHERE j.JobId IS NULL OR (SELECT COUNT(JobId)
				FROM Jobs
				WHERE Status <> 'Finished' AND MechanicId = m.MechanicId
				GROUP BY MechanicId, Status) IS NULL
	GROUP BY m.MechanicId, m.FirstName + ' ' +  m.LastName

--9.Past Expenses
SELECT 
		j.JobId,
		ISNULL(SUM(p.Price * op.Quantity), 0) AS Total
	FROM Jobs AS j
	LEFT JOIN Orders AS o ON o.JobId = j.JobId
	LEFT JOIN OrderParts AS op ON op.OrderId = o.OrderId
	LEFT JOIN Parts AS p ON p.PartId = op.PartId
	WHERE Status = 'Finished' 
	GROUP BY j.JobId
	ORDER BY Total DESC, j.JobId

--10.Missing Parts
SELECT 
		p.PartId,
		p.Description,
		pn.Quantity AS [Required],
		p.StockQty AS [In Stock],
		IIF(o.Delivered = 0, op.Quantity, 0) AS Ordered
	FROM Parts AS p
	LEFT JOIN PartsNeeded AS pn ON pn.PartId = p.PartId
	LEFT JOIN OrderParts AS op ON op.PartId = p.PartId
	LEFT JOIN Jobs AS j ON j.JobId = pn.JobId
	LEFT JOIN Orders AS o ON o.JobId = j.JobId
	WHERE j.Status  != 'Finished' AND p.StockQty + IIF(o.Delivered = 0, op.Quantity, 0) < pn.Quantity
	ORDER BY p.PartId 

--11.	Place Order
ALTER PROC usp_PlaceOrder (@JobId INT, @SerialNumber VARCHAR(50), @Qty INT)
AS
	DECLARE @Status VARCHAR(10) = 
		(SELECT Status FROM Jobs WHERE JobId = @JobId)

	DECLARE @PartId VARCHAR(10) = 
		(SELECT PartId FROM Parts WHERE SerialNumber = @SerialNumber)
	
	IF(@Qty <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1
	ELSE IF(@Status IS NULL)
		THROW 50013, 'Job not found!', 1
	ELSE IF(@Status = 'Finished')
		THROW 50011, 'This job is not active!', 1
	ELSE IF(@PartId IS NULL)
		THROW 50014, 'Part not found!', 1

	DECLARE @OrderId INT = 
		(SELECT OrderId 
			FROM Orders
			WHERE JobId = @JobId AND IssueDate IS NULL)

	IF(@OrderId IS NULL)
		BEGIN
			INSERT INTO Orders (JobId, IssueDate) VALUES
			(@JobId, NULL)
		END
			
	SET @OrderId = 
		(SELECT o.OrderId 
		FROM Orders AS o
		WHERE o.JobId = @JobId AND o.IssueDate IS NULL)

	DECLARE @OrderPartExist INT = 
		(SELECT OrderId 
			FROM OrderParts AS o 
			WHERE OrderId = @OrderId AND PartId = @PartId)

	IF(@OrderPartExist IS NULL)
	BEGIN
		INSERT INTO OrderParts (OrderId, PartId, Quantity) VALUES
		(@OrderId, @PartId, @Qty)
	END
	ELSE
		BEGIN
			UPDATE OrderParts
			SET Quantity += @Qty
			WHERE OrderId = @OrderId AND PartId = @PartId
		END	

DECLARE @err_msg AS NVARCHAR(MAX);
BEGIN TRY
  EXEC usp_PlaceOrder 1, 'ZeroQuantity', 0
END TRY

BEGIN CATCH
  SET @err_msg = ERROR_MESSAGE();
  SELECT @err_msg
END CATCH


--12.	Cost Of Order
CREATE FUNCTION udf_GetCost (@JobId INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
	DECLARE @Result DECIMAL(15,2);
	SET @Result = (SELECT 
						SUM(p.Price * op.Quantity) AS TotalSum
					FROM Jobs AS j
					JOIN Orders AS o ON o.JobId = j.JobId
					JOIN OrderParts AS op ON op.OrderId = o.OrderId
					JOIN Parts AS p ON p.PartId = op.PartId
					WHERE j.JobId = @JobId
					GROUP BY j.JobId)

	IF(@Result IS NULL)
		SET @Result = 0

	RETURN @Result
END

SELECT dbo.udf_GetCost (1)
