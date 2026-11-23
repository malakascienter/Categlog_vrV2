-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[Report_TransferRequestSummary] 1,'2026-01-28','15,14,16,7,12,1,8,13,21,19,20',4168,1

-- =============================================
CREATE   PROCEDURE [dbo].[Report_TransferRequestSummary]
    @PropertyID INT,
    @Date DATE,
    @MultipleLocationID VARCHAR(MAX),
    @UserID INT,
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        STI.StockItemCode,
        STI.Name AS ItemName,
        LO.NAME LocationName,

        
        CASE 
            WHEN CAST(RH.DeliveryDate AS DATE) > DATEADD(DAY, 4, @Date)
                THEN 'After5Days'
            ELSE CONVERT(VARCHAR(10), CAST(RH.DeliveryDate AS DATE), 120)
        END AS DeliveryDate,

       
        SUM(RD.ApprovedQuantity) AS Qty

    FROM RequestHeaders RH
    INNER JOIN RequestDetails RD ON RH.ID = RD.RequestHeaderID
    INNER JOIN StockItemHeaders STI ON STI.ID = RD.StockItemID
    INNER JOIN Locations LO ON LO.ID = RH.LocationID

    WHERE RH.RequestType = 'RT'
        AND RH.IsApproved = 1
        AND RH.DocumentStatus = 'P'
        AND RH.DeliveryDate >= @Date

        
        AND RH.TransferLocation IN (
            SELECT TRY_CAST(value AS INT) 
            FROM STRING_SPLIT(@MultipleLocationID, ',')
        )
        AND RH.LocationID = CASE 
                                WHEN @LocationID = -999 
                                THEN RH.LocationID 
                                ELSE @LocationID 
                            END

    GROUP BY 
        STI.StockItemCode,
        STI.Name,
        LO.NAME,
        CASE 
            WHEN CAST(RH.DeliveryDate AS DATE) > DATEADD(DAY, 4, @Date)
                THEN 'After5Days'
            ELSE CONVERT(VARCHAR(10), CAST(RH.DeliveryDate AS DATE), 120)
        END

    ORDER BY 
        STI.Name,
        DeliveryDate;

END

GO

