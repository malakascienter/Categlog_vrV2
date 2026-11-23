


--SPP_SaveBOQVersion 1,1,-1,-1
CREATE PROCEDURE SPP_SaveBOQVersion @BOQID INT,@Version INT,@BOQNEW INT OUTPUT,@OUTVersion INT OUTPUT

AS
BEGIN

SELECT * FROM dbo.BOQHeaders WHERE MainBoqId=@BOQID AND VersionNo=@Version

DECLARE @PREBOQID  INT

SELECT  @PREBOQID = ID FROM  dbo.BOQHeaders WHERE MainBoqId=@BOQID AND VersionNo=@Version
SELECT  @PREBOQID
	INSERT INTO BOQHeaders(
		[ProjectID],
		[BOQDate],
		[Approve],
		[ApprovedUserID],
		[ApprovedDate],
		[BOQStatus],
		[CurrentVersion],
		[isDisRate],
		[DisValue],
		[SundryValue],
		[BOQCode],
		[BOQName],
		[MainBoqId],
		[VersionNo]
		)
		SELECT ProjectID,BOQDate,0,1,ApprovedDate,BOQStatus,@Version+1,isDisRate,DisValue,SundryValue,BOQCode,BOQName,@BOQID,@Version+1 FROM dbo.BOQHeaders  WHERE MainBoqId=@BOQID AND VersionNo=@Version

		DECLARE @NEWBOQID INT
		SET  @NEWBOQID=SCOPE_IDENTITY()
		SET @BOQNEW= @NEWBOQID
		SELECT @OUTVersion=CurrentVersion FROM dbo.BOQHeaders WHERE ID=@NEWBOQID

		INSERT INTO dbo.BOQMainWorkAllocations
		        ( BOQID ,
		          Description ,
		          IsPercentageOrValue ,
		          DiscountPercentage ,
		          DiscountValue
		        )
		SELECT @BOQNEW,Description,IsPercentageOrValue,DiscountPercentage,DiscountValue FROM dbo.BOQMainWorkAllocations WHERE BOQID=@PREBOQID
		SELECT @PREBOQID
	INSERT INTO dbo.BOQSubWorkAllocations
	        ( BOQID ,
	          Description ,
	          Quantity ,
	          Rate ,
	          DepartmentID ,
	          Awarded ,
	          SeqNo ,
	          WorkID ,
	          MainWorkID ,
	          IsPercentageOrValue ,
	          DiscountPercentage ,
	          DiscountValue
	        )
	SELECT @NEWBOQID,Description,Quantity,Rate,DepartmentID,Awarded,SeqNo,WorkID,MainWorkID,IsPercentageOrValue,DiscountPercentage,DiscountValue FROM dbo.BOQSubWorkAllocations WHERE BOQID = @PREBOQID


	INSERT INTO dbo.BOQRateanalysisAllocationHeaders
	        ( BOQID ,
	          WorkID ,
	          RateQtyInWork ,
	          RateAnalysisID ,
	          Description ,
	          TotalPrice ,
	          Status ,
	          CreateUserId ,
	          CreateDate ,
	          AllocationUserID ,
	          AllocationDate ,
	          ProfitMarginPer ,
	          ProfitMarginVal ,
	          OverheadCostPer ,
	          OverheadCostVal ,
	          SundryValue ,
	          IsPercentageOrValue ,
	          DiscountPercentage ,
	          DiscountValue
	        )
	SELECT @NEWBOQID,WorkID,RateQtyInWork,RateAnalysisID,Description,TotalPrice,Status,CreateUserId,CreateDate,AllocationUserID,AllocationDate,ProfitMarginPer,ProfitMarginVal,OverheadCostPer,OverheadCostVal,SundryValue,IsPercentageOrValue,DiscountPercentage,DiscountValue FROM dbo.BOQRateanalysisAllocationHeaders
	

	INSERT INTO dbo.BOQRateanalysisAllocationDetails
	        ( BOQID ,
	          RateID ,
	          SequNo ,
	          Location ,
	          ItemType ,
	          Unit ,
	          UnitPrice ,
	          Quantity ,
	          ItemID ,
	          isAlternativeItemApplicable ,
	          isProjectspecificSubstituteItem ,
	          IsPercentageOrValue ,
	          DiscountPercentage ,
	          DiscountValue ,
	          ProfitMarginVal ,
	          OverheadCostVal ,
	          IPAddress ,
	          CreatedUserID ,
	          LastModUserID ,
	          CreatedDate ,
	          LastModDate ,
	          TotalTax
	        )
	SELECT @NEWBOQID,RateID,SequNo,Location,ItemType,Unit,UnitPrice,Quantity,ItemID,isAlternativeItemApplicable,isProjectspecificSubstituteItem,IsPercentageOrValue,DiscountPercentage,DiscountValue,
	ProfitMarginVal,OverheadCostVal,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate,TotalTax FROM dbo.BOQRateanalysisAllocationDetails







END

GO

