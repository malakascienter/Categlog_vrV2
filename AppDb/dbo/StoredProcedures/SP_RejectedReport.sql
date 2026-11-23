
-- =============================================
-- Author:        Ravindu
-- Create date:   2025-11-12
-- Description:   Rejected Transaction Report 

--  [dbo].[SP_RejectedReport]  'GR',-999,1,'2025-01-01','2025-10-30'

-- =============================================
CREATE PROCEDURE [dbo].[SP_RejectedReport] 
( 
    @Type VARCHAR(3),
    @LocationID INT,
    @CompanyID INT,
    @FromDate DATE,
    @ToDate DATE
)

AS
BEGIN
    --Get rejected GRN
    IF(@Type = 'GR')
    BEGIN 
        SELECT DISTINCT
        L.Name AS LocationName,
        S.Name AS SupplierName,
        GL.ApprovalDocNo AS RejectedDocNo,
        GL.ReferenceNo AS SupplierInvoiceNo,
        GL.Remarks AS RejectReason,
        CAST(GL.ApprovedDateTime AS DATE) AS RejectedDate,
        CAST(GL.CreatedDate AS DATE) AS CreatedDate,
        CUC.UserName AS CreatedUser,
        CUR.UserName AS RejectedUser
		,GL.LocationId
        FROM GRNApprovalLog AS GL
        INNER JOIN  Locations AS L ON GL.LocationId = L.Id
        INNER JOIN Suppliers AS S ON GL.SupplierId = S.ID
        INNER JOIN CentralUsers CUC ON CUC.Id = GL.CreatedUserId
        INNER JOIN CentralUsers CUR ON CUR.Id = GL.ApprovedUserId
        WHERE Status = 'X' 
             AND TransactionType = 'GR' 
             AND  CAST(GL.CreatedDate AS DATE) BETWEEN  @FromDate AND @ToDate
             AND GL.LocationId =CASE WHEN @LocationID = -999 THEN GL.LocationId ELSE @LocationID END
             AND GL.CompanyId = @CompanyID
        ORDER BY GL.LocationId;
    END


    --Get rejected Supplier Return
    IF(@Type = 'SR')
    BEGIN   
        SELECT DISTINCT
        L.Name AS LocationName,
        S.Name AS SupplierName,
        GL.ApprovalDocNo AS RejectedDocNo,
        GL.ReferenceNo AS SupplierInvoiceNo,
        GL.Remarks AS RejectReason,
        CAST(GL.ApprovedDateTime AS DATE) AS RejectedDate,
        CAST(GL.CreatedDate AS DATE) AS CreatedDate,
        CUC.UserName AS CreatedUser,
        CUR.UserName AS RejectedUser
		,GL.LocationId
        FROM GRNApprovalLog AS GL
        INNER JOIN  Locations AS L ON GL.LocationId = L.Id
        INNER JOIN Suppliers AS S ON GL.SupplierId = S.ID
        INNER JOIN CentralUsers CUC ON CUC.Id = GL.CreatedUserId
        INNER JOIN CentralUsers CUR ON CUR.Id = GL.ApprovedUserId
        WHERE Status = 'X' 
             AND TransactionType = 'SR' 
             AND  CAST(GL.CreatedDate AS DATE) BETWEEN  @FromDate AND @ToDate
             AND GL.LocationId = CASE WHEN @LocationID = -999 THEN GL.LocationId ELSE @LocationID END
             AND GL.CompanyId = @CompanyID
        ORDER BY GL.LocationId;
    END


    -- Get issue return rejected
    IF(@Type = 'IR')
    BEGIN
        SELECT DISTINCT
        L.Name AS LocationName,
        GL.ApprovalDocNo AS RejectedDocNo,
        GL.Remarks AS RejectReason,
        CAST(GL.ApprovedDateTime AS DATE) AS RejectedDate,
        CAST(GL.CreatedDate AS DATE) AS CreatedDate,
        CUC.UserName AS CreatedUser,
        CUR.UserName AS RejectedUser
		,GL.LocationId
        FROM GRNApprovalLog AS GL
        INNER JOIN  Locations AS L ON GL.LocationId = L.Id
        INNER JOIN CentralUsers CUC ON CUC.Id = GL.CreatedUserId
        INNER JOIN CentralUsers CUR ON CUR.Id = GL.ApprovedUserId
        WHERE Status = 'X' 
             AND TransactionType = 'IR' 
             AND  CAST(GL.CreatedDate AS DATE) BETWEEN  @FromDate AND @ToDate
             AND GL.LocationId = CASE WHEN @LocationID = -999 THEN GL.LocationId ELSE @LocationID END
             AND GL.CompanyId = @CompanyID
        ORDER BY GL.LocationId;
    END


    -- Get rejected stock reconcilation
    IF(@Type = 'AA')
    BEGIN 
        SELECT DISTINCT
        L.Name AS LocationName,
        GL.ApprovalDocNo AS RejectedDocNo,
        GL.Remarks AS RejectReason,
        CAST(GL.ApprovedDateTime AS DATE) AS RejectedDate,
        CAST(GL.CreatedDate AS DATE) AS CreatedDate,
        CUC.UserName AS CreatedUser,
        CUR.UserName AS RejectedUser
		,GL.LocationId
        FROM GRNApprovalLog AS GL
        INNER JOIN  Locations AS L ON GL.LocationId = L.Id
        INNER JOIN CentralUsers CUC ON CUC.Id = GL.CreatedUserId
        INNER JOIN CentralUsers CUR ON CUR.Id = GL.ApprovedUserId
        WHERE Status = 'X' 
             AND TransactionType = 'AA' 
             AND  CAST(GL.CreatedDate AS DATE) BETWEEN   @FromDate AND  @ToDate 
             AND GL.LocationId = CASE WHEN @LocationID = -999 THEN GL.LocationId ELSE @LocationID END
             AND GL.CompanyId = @CompanyID
        ORDER BY GL.LocationId;
    END 
END

GO

