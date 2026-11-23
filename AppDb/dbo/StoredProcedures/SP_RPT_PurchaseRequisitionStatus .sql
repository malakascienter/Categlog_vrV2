
-- [dbo].[SP_RPT_PurchaseRequisitionStatus ]  -999,'2024/01/01','2024/04/01'

CREATE PROCEDURE [dbo].[SP_RPT_PurchaseRequisitionStatus ](@LocationId INT,@FromDate DATE,@ToDate DATE)
AS
BEGIN

--Modified by Isuru 2024-03-19 for incorect item showing in Repor
CREATE TABLE #TempOut
	(ID INT IDENTITY,RequestHeaderID INT,PoHeaderId INT,StockTransactionHeaderID INT,ItemId INT,Location VARCHAR(100),PRNO VARCHAR(100)
	,RequestDate DATETIME,PRStatus VARCHAR(50),Item VARCHAR(100),UOM VARCHAR(20)
	,RequestedQuantity DECIMAL(18,2),
	 Dept VARCHAR(50),ApprovedQuantity DECIMAL(18,2),IssuedQuantity DECIMAL(18,2), Pending DECIMAL(18,2), ItemShortClose VARCHAR(10),
	 PoNo VARCHAR(100), POStatus VARCHAR(100),GRNNo VARCHAR(100), GRNDate DATETIME,DepartmentID INT,LocationID INT, Remarks VARCHAR(Max)
	 ,ApprovedUserName VARCHAR(MAX),ApprovalDate DATETIME)

	 INSERT INTO #TempOut(RequestHeaderID,PRNO,ItemId,ApprovedQuantity,IssuedQuantity,Pending,PRStatus,RequestedQuantity,RequestDate,DepartmentID,LocationID,ItemShortClose, Remarks,ApprovedUserName,ApprovalDate)
	 SELECT RH.Id,RH.DocumentNo,RD.StockItemID,RD.ApprovedQuantity,RD.IssuedQuantity,(RD.ApprovedQuantity- RD.IssuedQuantity) AS Pending,
	 CASE WHEN RH.DocumentStatus = 'P' AND RH.IsApproved = 0 THEN 'Pending'
	WHEN RH.DocumentStatus = 'P' AND RH.IsApproved = 1 THEN 'Approved' WHEN RH.DocumentStatus = 'X' THEN 'Rejected' WHEN RH.DocumentStatus = 'C' THEN 'Completed' END
	,RD.RequestedQuantity,RH.RequestDate,RH.DepartmentID,RH.LocationID,'',rh.Remarks
	,BQ.ApprovedUserName
	,BQ.ApprovalDate
	FROM RequestHeaders RH
	 INNER JOIN RequestDetails RD ON RH.ID = RD.RequestHeaderID
	 --ADDED BY ISURU 2026-1-06 TO get last approved user name and date
		OUTER APPLY dbo.fn_GetLastCompletedApproval(RH.Id,1,RH.PropertyID) AS BQ

	 WHERE RH.RequestType='RP' AND RH.RequestDate BETWEEN @FromDate AND @ToDate
	 AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID ELSE @LocationId END

	 UPDATE TP
	 SET TP.Item = SH.Name
	 FROM #TempOut TP
	 INNER JOIN StockItemHeaders SH ON TP.ItemId = SH.Id



	 UPDATE TP
	 SET TP.Location = LO.Name
	 FROM #TempOut TP
	 INNER JOIN Locations LO ON TP.LocationID = LO.Id

	 UPDATE TP
	 SET TP.Dept = DE.Name
	 FROM #TempOut TP
	 INNER JOIN Departments DE ON TP.DepartmentID = DE.Id


	UPDATE TP
	SET TP.PoHeaderId = PH.Id , TP.PoNo = PH.PoNo,
	TP.POStatus =CASE WHEN PH.DocumentStatus = 'P' AND PH.IsApproved = 0 THEN 'Pending'  
	WHEN PH.DocumentStatus = 'P' AND PH.IsApproved = 1 THEN 'Approved' WHEN PH.DocumentStatus = 'X' THEN 'Rejected' WHEN PH.DocumentStatus = 'C'
	 THEN 'Completed' END
	 FROM #TempOut TP 
	 INNER JOIN PoWisePRs PW ON TP.RequestHeaderID = PW.RequestHeaderID AND PW.StockItemID = TP.ItemId
	 INNER JOIN PoHeaders PH ON PH.Id = PW.PoHeaderID

	 UPDATE TP
	 SET TP.UOM = U.Name
	 FROM #TempOut TP 
	 INNER JOIN StockItemDetails SD ON TP.ItemId = SD.StockItemHeaderID
	 INNER JOIN Units U ON U.ID = SD.MasterUnitID


	 UPDATE TP
	 SET TP.StockTransactionHeaderID = STO.Id,TP.GRNNo = STO.DocumentNo,TP.GRNDate = STO.TransactionDate
	 FROM #TempOut TP
	 INNER JOIN StockTransactionHeaders STO ON TP.PoHeaderId = STO.ReferenceID
	 RIGHT join StockTransactionDetails std on std.StockTransactionHeaderID=sTO.id and TP.ItemId=std.StockItemID
	 WHERE STO.TransactionType='GR'
	  

	 SELECT *
	FROM #TempOut TP
	ORDER BY RequestDate DESC
	--WHERE GRNNo='AF/GR/005101'
	--End

	--Commented by Isuru 2024-03-19 for incorect item showing in Report

	 --SELECT DISTINCt L.Name AS Location,H.DocumentNo AS PRNO,H.RequestDate,CASE WHEN H.DocumentStatus = 'P' AND H.IsApproved = 0 THEN 'Pending'
	 --WHEN H.DocumentStatus = 'P' AND H.IsApproved = 1 THEN 'Approved' WHEN H.DocumentStatus = 'X' THEN 'Rejected' WHEN H.DocumentStatus = 'C' THEN 'Completed' END AS PRStatus,IH.Name AS Item,U.Name AS UOM,D.RequestedQuantity,
	 --DE.Name AS Dept, D.ApprovedQuantity,D.IssuedQuantity,(D.ApprovedQuantity- D.IssuedQuantity) AS Pending,'' ItemShortClose,
	 --PH.PoNo, CASE WHEN PH.DocumentStatus = 'P' AND PH.IsApproved = 0 THEN 'Pending'  WHEN PH.DocumentStatus = 'P' AND PH.IsApproved = 1 THEN 'Approved' WHEN PH.DocumentStatus = 'X' THEN 'Rejected' WHEN PH.DocumentStatus = 'C'
	 --THEN 'Completed' END AS POStatus,SH.DocumentNo  AS GRNNo, SH.TransactionDate AS GRNDate
	 --FROM RequestHeaders H 
	 --INNER JOIN RequestDetails D ON H.Id = D.RequestHeaderID  
	 --INNER JOIN Locations L ON L.Id = H.LocationID
	 --INNER JOIN StockItemHeaders IH ON IH.id = D.StockItemID 
	 --INNER JOIN StockItemDetails ID ON ID.StockItemHeaderID = IH.Id
	 --INNER JOIN Units U ON U.Id = ID.MasterUnitID
	 --INNER JOIN Departments De ON De.Id = H.DepartmentID
	 --LEFT JOIN PoWisePRs PO ON PO.RequestHeaderID = H.Id and po.StockItemID = d.StockItemID
	 --LEFT JOIN PoHeaders PH ON PH.Id = PO.PoHeaderID
	 --LEFT JOIN StockTransactionHeaders SH ON SH.ReferenceID =  PH.Id AND SH.TransactionType = 'GR'
	 --RIGHT join StockTransactionDetails std on std.StockTransactionHeaderID=sh.id and po.StockItemID=std.StockItemID
	 --WHERE H.RequestType = 'RP' AND H.LocationID = CASE WHEN @LocationId = -999 THEN H.LocationID ELSE @LocationId END
	 --AND H.RequestDate BETWEEN @FromDate AND @ToDate
	 --ORDER BY H.RequestDate DESC

	 --End
END

GO

