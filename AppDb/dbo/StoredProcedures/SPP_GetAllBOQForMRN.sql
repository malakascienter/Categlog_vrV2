-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
-- [dbo].[SPP_GetAllBOQForMRN] 11



CREATE PROCEDURE [dbo].[SPP_GetAllBOQForMRN] 

@projectID INT
	
	AS

	BEGIN


	DECLARE @Overhead decimal,@Labor decimal,@Material DECIMAL

	DECLARE @TEMPD TABLE (
	aid INT IDENTITY(1,1),
	id INT,
	ProjectID INT,
	BOQName  NVARCHAR(max),
	BOQDate DATE,
	Approve BIT,
	ApprovedUserID INT,
	ApprovedDate DATE,
	CurrentVersion INT,
	isDisRate BIT,
	DisValue DECIMAL,
	SundryValue DECIMAL,
	BOQCode NVARCHAR(max),
	BOQStatus BIT,
	Labor DECIMAL,
	Material DECIMAL,
	OVC DECIMAL
	)

	--select approved and finalized BOQ

    INSERT INTO @TEMPD
        ( id ,
          ProjectID ,
		  BOQDate,
		  BOQName,
          Approve ,
          ApprovedUserID ,
          ApprovedDate ,
          CurrentVersion ,
          isDisRate ,
          DisValue ,
          SundryValue ,
          BOQCode ,
          BOQStatus ,
          Labor ,
          Material ,
          OVC
        )
    SELECT dbo.BOQHeaders.Id,ProjectID,BOQDate,dbo.BOQHeaders.BOQName,Approve,ApprovedUserID,ApprovedDate,CurrentVersion,isDisRate,DisValue,SundryValue,BOQCode,BOQStatus,0,0,0
	FROM  dbo.Customers INNER JOIN
          dbo.ProjectDetails ON dbo.Customers.id = dbo.ProjectDetails.ClientID INNER JOIN
          dbo.BOQHeaders ON dbo.ProjectDetails.Id = dbo.BOQHeaders.ProjectID WHERE ProjectID=@projectID AND dbo.BOQHeaders.Approve=1 AND dbo.BOQHeaders.Finalized=1
    
	
   
   --SELECT * FROM @TEMPD   
   DECLARE @count INT = 1

   DECLARE @TEMPtotal TABLE (
	WorkID INT,
	RateHead INT,
	BoqID INT,
	RateSelecteHead INT, 
	PMV DECIMAL,
	OCV DECIMAL,
	DISValue DECIMAL,
	Qty DECIMAL,
	UnitPrice DECIMAL,
	ItemType NVARCHAR(max),
	isDisRate BIT,
	WorkDQty DECIMAL

)

   WHILE (@count <= (SELECT COUNT(1) FROM @TEMPD ))
   BEGIN 

   DECLARE @BOQID INT,@WORKID INT,@RATEID INT,@SundryID INT 
   SET @BOQID=NULL
   SELECT TOP(@count) @BOQID=id FROM @TEMPD
   --SELECT @BOQID

   INSERT INTO @TEMPtotal
        ( WorkID ,
          RateHead ,
          BoqID ,
		  RateSelecteHead,
          PMV ,
          OCV ,
          DISValue ,
          Qty,
		  UnitPrice,
		  ItemType,
		  isDisRate,
		  WorkDQty
        )
		SELECT           dbo.BOQSubWorkAllocations.WorkID, dbo.BOQRateanalysisAllocationHeaders.RateAnalysisID, dbo.BOQHeaders.Id AS BoqID, dbo.RateAnalysisHeaders.Id AS HeaderID,
		                 dbo.RateAnalysisDetails.ProfitMarginVal, 
                         dbo.RateAnalysisDetails.OverheadCostVal, dbo.RateAnalysisDetails.DisValue, dbo.RateAnalysisDetails.Quantity,dbo.RateAnalysisDetails.UnitPrice,
						 dbo.RateAnalysisDetails.ItemType,dbo.RateAnalysisDetails.isDisRate,dbo.BOQRateanalysisAllocationHeaders.RateQtyInWork
     FROM dbo.BOQHeaders INNER JOIN
                         dbo.BOQSubWorkAllocations ON dbo.BOQHeaders.Id = dbo.BOQSubWorkAllocations.BOQID INNER JOIN
                         dbo.BOQRateanalysisAllocationHeaders ON dbo.BOQSubWorkAllocations.WorkID = dbo.BOQRateanalysisAllocationHeaders.WorkID INNER JOIN
                         dbo.RateAnalysisHeaders ON dbo.BOQRateanalysisAllocationHeaders.RateAnalysisID = dbo.RateAnalysisHeaders.Id INNER JOIN
                         dbo.RateAnalysisDetails ON dbo.RateAnalysisHeaders.Id = dbo.RateAnalysisDetails.RateAnalysisHeaderID
     WHERE (dbo.BOQHeaders.Id = @BOQID)

     DECLARE @Laborall DECIMAL =0,@LaborallP DECIMAL =0,@Materialall DECIMAL =0,@OVC DECIMAL =0,@MaterialallP DECIMAL =0
     SELECT @Materialall=SUM((((UnitPrice*Qty)+PMV+OCV)-ISNULL(DISValue,0) *Qty )* WorkDQty) FROM @TEMPtotal WHERE ItemType='I' AND BoqID=@BOQID AND isDisRate=0
	   --SELECT @Materialall
	  SELECT @MaterialallP=SUM((((UnitPrice*Qty)+PMV+OCV)-((UnitPrice/100)*ISNULL(DISValue,0))*Qty )*WorkDQty) FROM @TEMPtotal WHERE ItemType='I' AND BoqID=@BOQID AND isDisRate=1	  

	
	 
	
	  --SELECT @MaterialallP


	 UPDATE @TEMPD SET Material=ISNULL(@Materialall,0)+ISNULL(@MaterialallP,0) WHERE id=@BOQID

	 SELECT @Laborall=SUM((((UnitPrice*Qty)+PMV+OCV)-ISNULL(DISValue,0)*Qty) * WorkDQty) FROM @TEMPtotal 
	 WHERE ItemType='L' AND BoqID=@BOQID AND isDisRate=0
	  --SELECT @Laborall

	 SELECT @LaborallP=SUM((((UnitPrice*Qty)+PMV+OCV)-((UnitPrice/100)*ISNULL(DISValue,0))*Qty ) * WorkDQty) FROM @TEMPtotal 
	 WHERE ItemType='L' AND BoqID=@BOQID AND isDisRate=1	
	 --SELECT @LaborallP

	
	  DECLARE @WorkQty DECIMAL
	  SELECT @WorkQty=WorkDQty FROM @TEMPtotal INNER JOIN dbo.BOQRateanalysisAllocationHeaders ON [@TEMPtotal].WorkID =dbo.BOQRateanalysisAllocationHeaders.WorkID 
	  WHERE BOQRateanalysisAllocationHeaders.BOQID=@BOQID
	  --SELECT @WorkQty


	 UPDATE @TEMPD SET Labor=ISNULL(@Laborall,0)+ISNULL(@LaborallP,0) WHERE id=@BOQID

	 SELECT @OVC=SUM(OCV) FROM @TEMPtotal WHERE BoqID=@BOQID
	 UPDATE @TEMPD SET OVC=@OVC WHERE id=@BOQID



	
	 --SELECT @WORKID=WorkID,@RATEID=RateHead FROM @TEMPtotal WHERE BoqID=@BOQID
	 --SELECT @SundryID=SundryValue FROM BOQRateanalysisAllocationHeaders WHERE WorkID=@WORKID AND RateAnalysisID=@RATEID AND BOQID=@BOQID

	 --UPDATE @TEMPD SET SundryValue=@SundryID WHERE id=@BOQID
	 SELECT @SundryID=SUM(SundryValue) FROM BOQRateanalysisAllocationHeaders WHERE BOQID=@BOQID
	 UPDATE @TEMPD SET SundryValue=@SundryID

	 SET  @count+=1

	 END 

	 --SELECT * FROM @TEMPtotal


	 SELECT * FROM @TEMPD
     




END

GO

