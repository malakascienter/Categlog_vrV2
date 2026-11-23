
CREATE PROCEDURE [dbo].[SP_Select_WorkDoneDetails] @projectId INT
AS
BEGIN
    DECLARE @Temp AS TABLE
    (
        ProjectID INT,
        BOQID INT,
        BOQCode VARCHAR(MAX),
        WorkDoneID INT,
        MainworkId INT,
        MainWorkName VARCHAR(MAX),
        WorkId INT,
        WorkName VARCHAR(MAX),
        AccessValue DECIMAL,
        BAmount DECIMAL
    );


    INSERT INTO @Temp
    (
        ProjectID,
        BOQID,
        BOQCode,
        WorkDoneID,
        MainworkId,
        MainWorkName,
        WorkId,
        WorkName,
        AccessValue,
        BAmount
    )
    SELECT WDR.ProjectID,
           WDR.BOQID,
           BH.BOQCode,
           WDR.Id AS WorkDoneID,
           WDR.MainWorkID AS MainworkId,
           MWA.Description AS MainWorkName,
           WDR.WorkID AS WorkId,
           WH.Description AS WorkName,
           WDR.Value AS AccessValue,
           ISNULL(
           (
               SELECT SUM(amount)
               FROM dbo.BillDetails
               WHERE BOQID = BH.Id
                     AND WorkDoneID = WDR.Id
                     AND MainWorkID = WDR.MainWorkID
                     AND WokeID = WDR.WorkID
           ),
           0
                 ) AS BAmount
    FROM dbo.BOQMainWorkAllocations AS MWA
        INNER JOIN dbo.WorkDoneRegistries AS WDR
            ON MWA.Id = WDR.MainWorkID
        INNER JOIN dbo.WorkHeaders AS WH
            ON WDR.WorkID = WH.Id
        INNER JOIN dbo.BOQHeaders BH
            ON BH.Id = WDR.BOQID
    WHERE WDR.ProjectID = @projectId;

    SELECT *
    FROM @Temp
    WHERE BAmount < AccessValue;

END;

GO

