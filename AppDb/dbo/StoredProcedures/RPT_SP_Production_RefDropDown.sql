-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-10-14
-- Description:	Production reference list for the Common Report "Select Option"
--				dropdown (InvenTory_ReportDetails.DropDownSP) of the Daily Production
--				Run and Recipe Consumption reports. 
--
--  [dbo].[RPT_SP_Production_RefDropDown]
-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_Production_RefDropDown]
AS
BEGIN

	SET NOCOUNT ON;

	SELECT X.id, X.text, X.ReportName, X.IsReportNameChange
	FROM
	(
		SELECT
			-999					AS id,
			N'--All--'				AS text,
			CAST(NULL AS NVARCHAR(250)) AS ReportName,
			CAST(0 AS BIT)			AS IsReportNameChange,
			0						AS SortGroup,
			CAST(NULL AS DATE)		AS SortDate,
			0						AS SortID

		UNION ALL

		SELECT
			PU.Id,
			ISNULL(PU.DocumentNo, N'-') + N' | ' + CONVERT(NVARCHAR(10), PU.TransactionDate, 103)
				+ ISNULL(N' | ' + RTRIM(SH.Name), N''),
			NULL,
			CAST(0 AS BIT),
			1,
			PU.TransactionDate,
			PU.Id
		FROM StockTransactionHeaders PU
		OUTER APPLY (SELECT TOP (1) PD.StockItemID
					 FROM StockTransactionDetails PD
					 WHERE PD.StockTransactionHeaderID = PU.Id) PD
		LEFT JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
		WHERE PU.TransactionType = 'PU'
	) X
	ORDER BY X.SortGroup, X.SortDate DESC, X.SortID DESC;

END

GO

