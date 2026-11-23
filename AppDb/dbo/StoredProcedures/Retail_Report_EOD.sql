-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-05-18
-- Description:	EOD Retail Report
/**
EXEC [dbo].[Retail_Report_EOD] '2026-05-17',18,2,1
	 
EXEC [dbo].[Retail_Report_EOD] '2026-05-17',18,2,2
	 
EXEC [dbo].[Retail_Report_EOD] '2026-05-17',18,2,3
	 
EXEC [dbo].[Retail_Report_EOD] '2026-05-17',18,2,4

**/
-- =============================================
CREATE PROCEDURE [dbo].[Retail_Report_EOD]
(          
 @FromDate	DATE,        
 @LocationID    VARCHAR(MAX),
 @PropertyId INT,
 @Type INT
)  
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @NoPax MONEY
	DECLARE @GrossSales MONEY
	DECLARE @NetSales MONEY
	DECLARE @FoodSales MONEY
	DECLARE @BevSales MONEY
	DECLARE @DeliverieSales MONEY
	DECLARE @EventSales MONEY
	DECLARE @ReatilsSales MONEY
	DECLARE @LocationName VARCHAR(MAX)

	IF( @Type = 1 )
	BEGIN

	SELECT @LocationName = NAME
	FROM Locations
	WHERE ID = @LocationID


		SELECT 
        COUNT(DISTINCT PH.InvoiceNo) AS NoPax,
		   SUM(
            (ID.Quantity * ID.SellingPrice)
        )AS GrossSaless,
        SUM(
            (ID.Quantity * ID.SellingPrice)
            - CASE 
                WHEN ID.DiscountValue = 0 
                    THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)
                ELSE ID.DiscountValue 
              END
        ) AS NetSales,
		@LocationName LocationName
    FROM POS_InvoiceHeader PH
    INNER JOIN POS_InvoiceDetail ID 
        ON PH.InvHeaderID = ID.InvHeaderID 
        AND PH.LocationID = ID.LocationID 
        AND PH.CompanyID = ID.CompanyID
    WHERE PH.LocationID = @LocationID
      AND PH.BusinessDate = @FromDate
	END
   IF( @Type = 2 )
   BEGIN
		DECLARE @GrossSales_2 MONEY
		DECLARE @PeakHour_2 VARCHAR(100)
		DECLARE @PeakHourSale_2 MONEY
		DECLARE @AvgDineinBillValue_2 MONEY
		DECLARE @AvgTakeAwayBillValue_2 MONEY
		DECLARE @CurrMonthFirstDate_2 DATETIME
		DECLARE @ReportDate_2 DATETIME
		DECLARE @CurrYearFirstDate_2 DATETIME
		DECLARE @MTD_2 MONEY
		DECLARE @YTD_2 MONEY
		DECLARE @CurrYearFirstDate DATE
		DECLARE @MTD_2_Tar MONEY
		DECLARE @YTD_2_Tar MONEY
		DECLARE @MTD_2_Pre MONEY
		DECLARE @YTD_2_Pre MONEY

		SET @CurrMonthFirstDate_2=(SELECT DATEADD(m, DATEDIFF(m, 0, CONVERT(datetime,@FromDate,103)), 0))
		SET  @ReportDate_2 =CONVERT(DATETIME,@FromDate,103)
		SET @CurrYearFirstDate = 
		CASE 
			WHEN MONTH(CONVERT(DATETIME,@FromDate,103)) >= 4 
			THEN DATEFROMPARTS(YEAR(CONVERT(DATETIME,@FromDate,103)), 4, 1) 
			ELSE DATEFROMPARTS(YEAR(CONVERT(DATETIME,@FromDate,103)) - 1, 4, 1) 
		END

		SELECT @GrossSales_2 = SUM((ID.Quantity * ID.SellingPrice) - CASE WHEN ID.DiscountValue = 0 THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)ELSE ID.DiscountValue END)
		FROM POS_InvoiceHeader PH
		INNER JOIN POS_InvoiceDetail ID 
			ON PH.InvHeaderID = ID.InvHeaderID 
			AND PH.LocationID = ID.LocationID 
			AND PH.CompanyID = ID.CompanyID
		WHERE PH.LocationID = @LocationID
		  AND PH.BusinessDate = @FromDate;


			SELECT @MTD_2 =  SUM((ID.Quantity * ID.SellingPrice) - CASE WHEN ID.DiscountValue = 0 THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)ELSE ID.DiscountValue END)
			FROM POS_InvoiceHeader PH
			INNER JOIN POS_InvoiceDetail ID 
			ON PH.InvHeaderID = ID.InvHeaderID 
			AND PH.LocationID = ID.LocationID 
			AND PH.CompanyID = ID.CompanyID
			WHERE PH.LocationID = @LocationID
			AND PH.BusinessDate >= CONVERT(DATE,@CurrMonthFirstDate_2,103) 
			AND  PH.BusinessDate <= CONVERT(DATE,@ReportDate_2,103);

			
			SELECT @YTD_2 =  SUM((ID.Quantity * ID.SellingPrice) - CASE WHEN ID.DiscountValue = 0 THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)ELSE ID.DiscountValue END)
			FROM POS_InvoiceHeader PH
			INNER JOIN POS_InvoiceDetail ID 
			ON PH.InvHeaderID = ID.InvHeaderID 
			AND PH.LocationID = ID.LocationID 
			AND PH.CompanyID = ID.CompanyID
			WHERE PH.LocationID = @LocationID
			AND PH.BusinessDate >= CONVERT(DATE,@CurrYearFirstDate,103) 
			AND  PH.BusinessDate <= CONVERT(DATE,@ReportDate_2,103);


		WITH HourlySales AS (
		SELECT 
			DATEPART(HOUR, PH.InsertDateTime) AS OrderHour,
			SUM(
				(ID.Quantity * ID.SellingPrice) - 
				CASE  
					WHEN ID.DiscountValue = 0 
						THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)
					ELSE ID.DiscountValue 
				END
			) AS NetSales
		FROM POS_InvoiceHeader PH
		INNER JOIN POS_InvoiceDetail ID 
			ON PH.InvHeaderID = ID.InvHeaderID 
			AND PH.LocationID = ID.LocationID 
			AND PH.CompanyID = ID.CompanyID
		WHERE PH.LocationID = @LocationID
		  AND PH.BusinessDate = @FromDate
		GROUP BY DATEPART(HOUR, PH.InsertDateTime)
	)
	SELECT TOP 1	
		@PeakHour_2 = OrderHour,@PeakHourSale_2 =NetSales
	FROM HourlySales
	ORDER BY NetSales DESC;


	

	SELECT CONVERT(VARCHAR,@FromDate) + ' Sale' AS Description,FORMAT(@GrossSales_2, 'N2') as ValueText
	UNION ALL
	SELECT 'Peak Hour' AS Description,@PeakHour_2 as ValueText
	UNION ALL
	SELECT 'Peak HourSale' AS Description,FORMAT(@PeakHourSale_2, 'N2') as ValueText
	UNION ALL
	SELECT 'MTD' AS Description,FORMAT(@MTD_2, 'N2') as ValueText
	UNION ALL
	SELECT 'YTD' AS Description,FORMAT(@YTD_2, 'N2') as ValueText
   END

   IF(@Type = 3)
   BEGIN
		SELECT PT.Description,SUM(PTD.ActualAmount) ActualAmount
		FROM POS_InvoicePayment PTD
		INNER JOIN PaymentTypes PT ON PT.PayCode = PTD.PayCode
		WHERE PTD.LocationID = @LocationID
		  AND PTD.BusinessDate = @FromDate
		GROUP BY PT.Description
   END

   IF(@Type = 4)
   BEGIN
		WITH ItemSales AS
		(SELECT CA.ID AS CategoryID,CA.Name CategoryName,
			SIH.ID AS ItemID,SIH.Name ItemName,
			SUM((ID.Quantity * ID.SellingPrice) 
				- CASE  
					WHEN ID.DiscountValue = 0 
					THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)
					ELSE ID.DiscountValue 
				  END) AS NetSales,
			ROW_NUMBER() OVER (
				PARTITION BY CA.ID 
				ORDER BY 
					SUM((ID.Quantity * ID.SellingPrice) 
						- CASE  
							WHEN ID.DiscountValue = 0 
							THEN (ID.Quantity * ID.SellingPrice * ID.DiscountPercentage / 100)
							ELSE ID.DiscountValue 
						  END
					) DESC) AS RN
		FROM POS_InvoiceHeader PH
		INNER JOIN POS_InvoiceDetail ID 
			ON PH.InvHeaderID = ID.InvHeaderID 
			AND PH.LocationID = ID.LocationID 
			AND PH.CompanyID = ID.CompanyID
		INNER JOIN StockItemHeaders SIH 
			ON SIH.ID = ID.ItemID
		INNER JOIN Categories CA 
			ON CA.ID = SIH.CategoryID

		WHERE PH.LocationID = @LocationID 
		  AND PH.BusinessDate = @FromDate

		GROUP BY 
			CA.ID, CA.Name,
			SIH.ID, SIH.Name
		)

		SELECT *
		FROM ItemSales
		WHERE RN <= 3
		ORDER BY CategoryID, RN;

   END
END

GO

