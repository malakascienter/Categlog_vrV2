
CREATE PROCEDURE [dbo].[Report_Costing_Revenue] 
	@FromDate	VARCHAR(20),
	@PropertyId INT,
	@CostingId INT
AS
BEGIN
SET NOCOUNT ON;
	SET DATEFORMAT DMY

	DECLARE @ReportDate DATE
	
	SET @ReportDate =CONVERT(DATE,@FromDate,103)

	IF OBJECT_ID(N'tempdb..#TempRv') IS NOT NULL
	BEGIN
	DROP TABLE #TempRv
	END
	
CREATE TABLE #TempRv
	(	
		Compcode char(3) not null default '',
		MasterID char(5) not null default '',
		PropertyID int not null default 0,	
		--ICID int not null default 0,
		--ItemCategory varchar(200) not null default '',
		AccountName varchar(200) not null default '',
		AmountTD money not null default 0,
		AmountMTD money not null default 0,
	)

INSERT INTO #TempRv
EXEC [GL_DAILYFOODCOSTINGSUMMERY] @ReportDate,@PropertyId,@CostingId
INSERT INTO #TempRv
EXEC [GL_DAILYFOODALLOCATIONSUMMERY] @ReportDate,@PropertyId,@CostingId


SELECT  * FROM #TempRv

	IF OBJECT_ID(N'tempdb..#TempRv') IS NOT NULL
	BEGIN
	DROP TABLE #TempRv
	END

END

GO

