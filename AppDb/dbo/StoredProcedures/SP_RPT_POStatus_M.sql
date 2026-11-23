--USE [Monarch-2022-09-06]
--GO
--/****** Object:  StoredProcedure [dbo].[SP_RPT_POStatus_M]    Script Date: 20/10/2022 1:57:09 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- [dbo].[SP_RPT_POStatus_M] 1,-999,'A',-999,'2025-09-04','2026-09-04'

----go

 
CREATE PROCEDURE [dbo].[SP_RPT_POStatus_M] (@CompanyId INT = 1, @LocationId INT = -999,@Status char(2)='A'
,@SupplierID int =-999, @CategoryID int=-999, @fromDate Date= '2022-10-01', @toDate Date= '2037-10-01')
AS
BEGIN

	IF(@Status ='X') -- CANCELLED PO
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
		,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		FROM PoHeaders PH 
		INNER JOIN PoDetails PD with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW with (nolock) ON PW.PoHeaderID = PH.Id AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH with (nolock) ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD with (nolock) ON RD.RequestHeaderID = RH.Id AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD with (nolock)ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST with (nolock) ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN Locations l with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN with (nolock) on ptn.Id = ph.POType

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PH.DocumentStatus = 'X'
		AND PH.DocumentDate between @fromdate and @todate
		ORDER BY PH.CreatedDate desc
	END

	IF(@Status ='C') -- COMPLETED PO
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
			,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		,BQ.ApprovedUserName
		,BQ.ApprovalDate
		
		FROM PoHeaders PH with (nolock)
		INNER JOIN PoDetails PD with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW with (nolock) ON PW.PoHeaderID = PH.Id AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH with (nolock) ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD with (nolock) ON RD.RequestHeaderID = RH.Id AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD with (nolock) ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST with (nolock) ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN Locations l with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN with (nolock) on ptn.Id = ph.POType

		--ADDED BY ISURU 2026-1-06 TO get last approved user name and date
		OUTER APPLY dbo.fn_GetLastCompletedApproval(PH.Id,2,PH.PropertyID) AS BQ

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PH.DocumentStatus = 'C'
		AND PH.DocumentDate between @fromdate and @todate
		ORDER BY PH.CreatedDate desc
	END
	IF(@Status ='P') -- PARTIAL  PO
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.DocumentStatus = 'C' THEN 'Completed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
			,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		,BQ.ApprovedUserName
		,BQ.ApprovalDate
		FROM PoHeaders PH 
		INNER JOIN PoDetails PD with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW with (nolock) ON PW.PoHeaderID = PH.Id AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH with (nolock) ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD with (nolock) ON RD.RequestHeaderID = RH.Id AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD with (nolock) ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST with (nolock) ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN Locations l with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN with (nolock) on ptn.Id = ph.POType
		--ADDED BY ISURU 2026-1-06 TO get last approved user name and date
		OUTER APPLY dbo.fn_GetLastCompletedApproval(PH.Id,2,PH.PropertyID) AS BQ

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PD.ReceivedQuantity >0
		AND PD.ApprovedQuantity - PD.ReceivedQuantity >0
		AND PH.DocumentDate between @fromdate and @todate
		ORDER BY PH.CreatedDate desc
	END

	IF(@Status ='O') -- OPEN  PO
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.DocumentStatus = 'C' THEN 'Completed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
			,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		,BQ.ApprovedUserName
		,BQ.ApprovalDate
		FROM PoHeaders PH 
		INNER JOIN PoDetails PD with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW with (nolock) ON PW.PoHeaderID = PH.Id  AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH with (nolock)ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD with (nolock) ON RD.RequestHeaderID = RH.Id AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD with (nolock) ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN Locations l with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN with (nolock) on ptn.Id = ph.POType
		--ADDED BY ISURU 2026-1-06 TO get last approved user name and date
		OUTER APPLY dbo.fn_GetLastCompletedApproval(PH.Id,2,PH.PropertyID) AS BQ

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PH.DocumentStatus = 'P' 
		AND  PD.ReceivedQuantity=0 
		AND PH.IsApproved = 1
		AND PH.DocumentDate between @fromdate and @todate
		ORDER BY PH.CreatedDate desc
	END

	IF(@Status ='PE') -- Pending   PO
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.DocumentStatus = 'C' THEN 'Completed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
			,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		FROM PoHeaders PH 
		INNER JOIN PoDetails PD with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW with (nolock) ON PW.PoHeaderID = PH.Id AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH with (nolock) ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD with (nolock) ON RD.RequestHeaderID = RH.Id  AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD with (nolock) ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST with (nolock) ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN Locations l with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN with (nolock) on ptn.Id = ph.POType

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PH.DocumentStatus = 'P' 
		AND PH.IsApproved = 0
		AND PH.DocumentDate between @fromdate and @todate
		ORDER BY PH.CreatedDate desc
	END

	IF(@Status ='A') -- ALL POs
	BEGIN
		SELECT DISTINCT PH.DocumentDate, U.UserName AS PORaisedBy,PH.PoNo,RH.DocumentNo AS PRNo,S.Code AS VendorCode, S.Name AS Vendor,
		C.Name AS CatNamee, SH.StockItemCode, SH.Name AS ItemName,Un.Name AS Unit, CASE WHEN PH.DocumentStatus = 'C' THEN 'Closed' WHEN PH.DocumentStatus = 'C' THEN 'Completed' WHEN PH.isApproved = 0 AND PH.DocumentStatus = 'P' THEN 'Pending' WHEN PH.isApproved = 1 AND PH.DocumentStatus = 'P' THEN 'Accepted' WHEN PH.DocumentStatus = 'X' THEN 'Rejected'  END AS Status,
		PH.DeliveryDate AS POReleasedDate, PH.CreatedDate  AS POCreatedDate, RH.RequestDate AS PRCreatedDate, RH.DeliveryDate, CM.Name AS Currency,
		PD.RequestedQuantity, PD.ReceivedQuantity,(PD.RequestedQuantity - PD.ReceivedQuantity) AS PendingQty,
		PD.UnitPrice    AS NetPrice , PD.RequestedQuantity * PD.UnitPrice AS Value,
		AL.Remarks AS RejectReason, 
		isnull(ptn.name,'General') as POType
		--case when ph.POType is null then 'General' else ptn.Name  end as POType
			,isnull(ph.Remarks,'') HEADERREMARK
		,isnull(PD.Remarks,'') ItemRemark
		--,ST.DocumentNo GRNno,FORMAT(ST.CreatedDate,'dd/MM/yyyy') GRNDate,l.Name AS GRNLoc
		,BQ.ApprovedUserName
		,BQ.ApprovalDate
		
		FROM PoHeaders PH with (nolock)
		INNER JOIN PoDetails PD  with (nolock) ON PH.Id = PD.PoHeaderID
		INNER JOIN PoWisePRs PW  with (nolock) ON PW.PoHeaderID = PH.Id AND PD.StockItemID = PW.StockItemID
		LEFT JOIN CentralUsers U  with (nolock) ON U.Id = PH.UserProfileID 
		LEFT JOIN RequestHeaders RH  with (nolock) ON RH.id = PW.RequestHeaderID
		LEFT JOIN RequestDetails RD  with (nolock)ON RD.RequestHeaderID = RH.Id AND RD.StockItemID= PW.StockItemID
		INNER JOIN Suppliers S  with (nolock) ON S.Id =  PH.SupplierID
		LEFT JOIN CurrencyMasters  CM  with (nolock) ON CM.Id = S.CurrencyID
		INNER JOIN StockItemHeaders SH  with (nolock) ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD  with (nolock) ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C  with (nolock) On C.Id = SH.CategoryID
		INNER JOIN Units Un  with (nolock) ON Un.Id = SD.MasterUnitID
		--LEFT JOIN StockTransactionHeaders ST with (nolock) ON ST.ReferenceID = PH.Id AND ST.TransactionType = 'GR'
		--LEFT JOIN STOCKTRANSACTIONDETAILS STD ON STD.StockTransactionHeaderID = ST.ID AND STD.StockItemID = PD.StockItemID
		--LEFT JOIN Locations l  with (nolock) ON l.Id = ST.LocationID
		LEFT JOIN POwiseTaxes PX  with (nolock) ON PX.PODetailID = PD.Id
		LEFT JOIN ApprovalLogs AL  with (nolock) ON AL.TransactionHeaderID = PH.Id --AND AL.DocStatus = 'X'
		LEFT JOIN PoTypesNew PTN  with (nolock) on ptn.Id = ph.POType
		--ADDED BY ISURU 2026-1-06 TO get last approved user name and date
		OUTER APPLY dbo.fn_GetLastCompletedApproval(PH.Id,2,PH.PropertyID) AS BQ

		WHERE PH.PropertyID = @CompanyId 
		AND PH.LocationID = CASE WHEN @LocationId = -999 THEN PH.LocationID ELSE @LocationId END
		AND PH.SupplierID = CASE WHEN @SupplierID = -999 THEN PH.SupplierID ELSE @SupplierID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND PH.DocumentDate between @fromdate and @todate
		
		ORDER BY PH.CreatedDate desc
	END
 

	
END

GO

