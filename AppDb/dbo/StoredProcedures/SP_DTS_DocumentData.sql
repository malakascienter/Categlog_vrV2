-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-05
-- Description:	Loading Document Data for DTS Systems

-- [dbo].[SP_DTS_DocumentData] '2026-01-01','2026-02-01','GRN','-999'

-- =============================================
create PROCEDURE [dbo].[SP_DTS_DocumentData]
@FromDate DATE = NULL,
@ToDate DATE NULL,
@DocumentType CHAR(3) ='-999',
@department_code VARCHAR(5) = '-999'
AS
BEGIN
	SET NOCOUNT ON;

    SELECT SH.DocumentNo document_id
	,CASE WHEN SH.TransactionType = 'GR' THEN 'GRN' WHEN  SH.TransactionType = 'SR' THEN 'SRN' END AS document_type,
	LO.Code department_code,SH.TransactionDate document_date,SH.Remarks remark
	FROM StockTransactionHeaders SH
	INNER JOIN Locations LO ON SH.LocationID = LO.Id
	WHERE SH.TransactionType IN ('GR','SR')
	AND SH.TransactionType = CASE WHEN @DocumentType = 'GRN' THEN 'GR' WHEN  @DocumentType = 'SRN' THEN 'SR' ELSE SH.TransactionType END
	AND LO.Code = CASE WHEN  @department_code = '-999' THEN LO.CODE ELSE  @department_code END
	      AND (
            @FromDate IS NULL
            OR @ToDate IS NULL
            OR SH.TransactionDate BETWEEN @FromDate AND @ToDate
          )
	
END

GO

