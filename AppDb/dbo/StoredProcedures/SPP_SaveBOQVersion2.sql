

--[dbo].[SPP_SaveBOQVersion2] 1,1,-1,-1

CREATE PROCEDURE [dbo].[SPP_SaveBOQVersion2]
    @BOQID INT ,
    @Version INT ,
    @BOQNEW INT OUTPUT ,
    @OUTVersion INT OUTPUT
AS

DECLARE @statusIN[INT],@message NVARCHAR(max),@status[int] 

    BEGIN
BEGIN TRY
	BEGIN TRANSACTION

 
        IF OBJECT_ID('tempdb..#Temp1') IS NOT NULL
            BEGIN
                DROP TABLE #Temp1;
            END
        IF OBJECT_ID('tempdb..#Temp2') IS NOT NULL
            BEGIN
                DROP TABLE #Temp2;
            END
        IF OBJECT_ID('tempdb..#Temp3') IS NOT NULL
            BEGIN
                DROP TABLE #Temp3;
            END
        IF OBJECT_ID('tempdb..#Temp4') IS NOT NULL
            BEGIN
                DROP TABLE #Temp4;
            END
        IF OBJECT_ID('tempdb..#Temp5') IS NOT NULL
            BEGIN
                DROP TABLE #Temp5;
            END

		DECLARE @MainBOQID INT,@Maxversion INT
		SELECT @MainBOQID= MainBOQID FROM dbo.BOQHeaders WHERE Id= @BOQID


		SELECT @Maxversion=MAX(VersionNo) FROM dbo.BOQHeaders WHERE MainBoqId=(SELECT MainBoqId FROM dbo.BOQHeaders WHERE id =@BOQID)


        SELECT  *
        FROM    dbo.BOQHeaders
        WHERE   Id = @BOQID
               
         
        DECLARE @PREBOQID INT

        SELECT  @PREBOQID = Id
        FROM    dbo.BOQHeaders
        WHERE   Id = @BOQID
               
			  

        SELECT  @PREBOQID
        INSERT  INTO BOQHeaders
                ( [ProjectID] ,
                  [BOQDate] ,
                  [Approve] ,
                  [ApprovedUserID] ,
                  [ApprovedDate] ,
                  [BOQStatus] ,
                  [CurrentVersion] ,
                  [isDisRate] ,
                  [DisValue] ,
                  [SundryValue] ,
                  [BOQCode] ,
                  [BOQName] ,
                  [MainBoqId] ,
                  [VersionNo],
				  [OHPmaterial],
				  [OHPlabour]
		        )
                SELECT  ProjectID ,
                        BOQDate ,
                        0 ,
                        1 ,
                        ApprovedDate ,
                        BOQStatus ,
                        @Maxversion + 1 ,
                        isDisRate ,
                        DisValue ,
                        SundryValue ,
                        BOQCode ,
                        BOQName ,
                        @MainBOQID ,
                        @Maxversion + 1,
						OHPmaterial,
						OHPlabour
                FROM    dbo.BOQHeaders
                WHERE   Id = @BOQID
                       

        DECLARE @NEWBOQID INT
        SET @NEWBOQID = SCOPE_IDENTITY()
        SET @BOQNEW = @NEWBOQID
        SELECT  @OUTVersion = CurrentVersion
        FROM    dbo.BOQHeaders
        WHERE   Id = @NEWBOQID

		--SELECT Id,@NEWBOQID,Description,Quantity,Rate,DepartmentID,Awarded,SeqNo,WorkID,MainWorkID,IsPercentageOrValue,DiscountPercentage,DiscountValue INTO #TEMP2 FROM dbo.BOQSubWorkAllocations WHERE BOQID = @PREBOQID WITH (Id INT,BOQID INT ,
	 --         Description VARCHAR(255) ,
	 --         Quantity decimal ,
	 --         Rate decimal,
	 --         DepartmentID INT,
	 --         Awarded BIT,
	 --         SeqNo INT ,
	 --         WorkID INT ,
	 --         MainWorkID INT,
	 --         IsPercentageOrValue BIT,
	 --         DiscountPercentage decimal,
	 --         DiscountValue decimal
		--)

        CREATE TABLE #Temp1
            (
              Id INT ,
              BOQID INT ,
              Description NVARCHAR(150) ,
              IsPercentageOrValue BIT ,
              DiscountPercentage DECIMAL ,
              DiscountValue DECIMAL
            )

        CREATE TABLE #Temp2
            (
              Id INT ,
              BOQID INT ,
              Description VARCHAR(255) ,
              Quantity DECIMAL ,
              Rate DECIMAL ,
              DepartmentID INT ,
              Awarded BIT ,
              SeqNo INT ,
              WorkID INT ,
              MainWorkID INT ,
              IsPercentageOrValue BIT ,
              DiscountPercentage DECIMAL ,
              DiscountValue DECIMAL,
			  SundryAmount DECIMAL,
			  OHPValue DECIMAL
            )  

		  

        CREATE TABLE #Temp3
            (
              Id INT ,
              WorkID INT ,
              RateAnalysisHeaderID INT ,
              Quantity DECIMAL ,
              Rate DECIMAL ,
              IPAddress NVARCHAR(MAX) ,
              CreatedUserID INT ,
              LastModUserID INT ,
              CreatedDate DATETIME ,
              LastModDate DATETIME
            )


        CREATE TABLE #Temp4
            (
              Id INT ,
              BOQID INT ,
              WorkID INT ,
              RateQtyInWork FLOAT ,
              RateAnalysisID INT ,
              Description NVARCHAR(MAX) ,
              TotalPrice DECIMAL ,
              Status BIT ,
              CreateUserId INT ,
              CreateDate DATETIME ,
              AllocationUserID INT ,
              AllocationDate DATETIME ,
              ProfitMarginPer FLOAT ,
              ProfitMarginVal FLOAT ,
              OverheadCostPer FLOAT ,
              OverheadCostVal FLOAT ,
              SundryValue DECIMAL ,
              IsPercentageOrValue BIT ,
              DiscountPercentage DECIMAL ,
              DiscountValue DECIMAL
            )

        CREATE TABLE #Temp5
            (
              ID INT ,
              BOQID INT ,
              RateID INT ,
              SequNo INT ,
              Location INT ,
              ItemType NVARCHAR(MAX) ,
              Unit INT ,
              UnitPrice FLOAT ,
              Quantity FLOAT ,
              ItemID INT ,
              isAlternativeItemApplicable BIT ,
              isProjectspecificSubstituteItem BIT ,
              IsPercentageOrValue BIT ,
              DiscountPercentage DECIMAL ,
              DiscountValue DECIMAL ,
              ProfitMarginVal DECIMAL ,
              OverheadCostVal DECIMAL ,
              IPAddress NVARCHAR(MAX) ,
              CreatedUserID INT ,
              LastModUserID INT ,
              CreatedDate DATETIME ,
              LastModDate DATETIME ,
              TotalTax DECIMAL
            )
           

		   Create Table #Temp6
		   (
				Id int,
				RateHeaderId int ,
				Cost decimal(18, 0) ,
				CategoryId int,
				Percentage decimal(18, 0),
				BoqId int,
				ItemId int
		   )


        INSERT  INTO #Temp1
                ( Id ,
                  BOQID ,
                  Description ,
                  IsPercentageOrValue ,
                  DiscountPercentage ,
                  DiscountValue
                )
                SELECT  Id ,
                        @BOQNEW ,
                        Description ,
                        IsPercentageOrValue ,
                        DiscountPercentage ,
                        DiscountValue
                FROM    dbo.BOQMainWorkAllocations
                WHERE   BOQID = @PREBOQID 


	   

        DECLARE @MainID INT ,
            @NewMainWorkAllocationID INT ,
            @OldSubworkID INT ,
            @NEWSubworkID INT
        WHILE ( ( SELECT    COUNT(Id)
                  FROM      #Temp1
                ) > 0 )
            BEGIN

                SELECT TOP ( 1 )
                        @MainID = Id
                FROM    #Temp1
               

                INSERT  INTO dbo.BOQMainWorkAllocations
                        ( BOQID ,
                          Description ,
                          IsPercentageOrValue ,
                          DiscountPercentage ,
                          DiscountValue
		                )
                        SELECT TOP ( 1 )
                                @BOQNEW ,
                                Description ,
                                IsPercentageOrValue ,
                                DiscountPercentage ,
                                DiscountValue
                        FROM    #Temp1
                        


                SET @NewMainWorkAllocationID = SCOPE_IDENTITY()
                DELETE  FROM #Temp1
                WHERE   Id = @MainID

					
                INSERT  INTO #Temp2
                        ( Id ,
                          BOQID ,
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
                          DiscountValue,
						  SundryAmount,
						  OHPValue
					    )
                        SELECT  Id ,
                                @NEWBOQID ,
                                Description ,
                                Quantity ,
                                Rate ,
                                DepartmentID ,
                                Awarded ,
                                SeqNo ,
                                WorkID ,
                                @NewMainWorkAllocationID ,
                                IsPercentageOrValue ,
                                DiscountPercentage ,
                                DiscountValue,
								SundryAmount,
								OHPValue
                        FROM    dbo.BOQSubWorkAllocations
                        WHERE   BOQID = @PREBOQID
                                AND MainWorkID = @MainID
								--change
            



                WHILE ( ( SELECT    COUNT(Id)
                          FROM      #Temp2
                        ) > 0 )
                    BEGIN


                        SELECT TOP ( 1 )
                                @OldSubworkID = Id
                        FROM    #Temp2

                        INSERT  INTO dbo.BOQSubWorkAllocations
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
                                  DiscountValue,
								  SundryAmount,
								  OHPValue
			                    )
                                SELECT TOP ( 1 )
                                        BOQID ,
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
                                        DiscountValue,
										SundryAmount,
										OHPValue
                                FROM    #Temp2

                        SET @NEWSubworkID = SCOPE_IDENTITY()
                        DELETE  FROM #Temp2
                        WHERE   Id = @OldSubworkID
			
                        INSERT  INTO #Temp3
                                ( Id ,
                                  WorkID ,
                                  RateAnalysisHeaderID ,
                                  Quantity ,
                                  Rate ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
			                    )
                                SELECT  Id ,
                                        @NEWSubworkID ,
                                        RateAnalysisHeaderID ,
                                        Quantity ,
                                        Rate ,
                                        IPAddress ,
                                        CreatedUserID ,
                                        LastModUserID ,
                                        CreatedDate ,
                                        LastModDate
                                FROM    WorkDetails
                                WHERE   WorkID = @OldSubworkID
								--change
                       
								


                        INSERT  INTO dbo.WorkDetails
                                ( WorkID ,
                                  RateAnalysisHeaderID ,
                                  Quantity ,
                                  Rate ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
			                    )
                                SELECT  WorkID ,
                                        RateAnalysisHeaderID ,
                                        Quantity ,
                                        Rate ,
                                        IPAddress ,
                                        CreatedUserID ,
                                        LastModUserID ,
                                        CreatedDate ,
                                        LastModDate
                                FROM    #Temp3

                        TRUNCATE TABLE #Temp3

                        INSERT  INTO #Temp4
                                ( Id ,
                                  BOQID ,
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
                                SELECT  ID ,
                                        @BOQNEW ,
                                        @NEWSubworkID,
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
                                FROM    dbo.BOQRateanalysisAllocationHeaders
                                WHERE   BOQID = @PREBOQID
                                        AND WorkID = @OldSubworkID

                        INSERT  INTO dbo.BOQRateanalysisAllocationHeaders
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
                                SELECT  BOQID ,
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
                                FROM    #Temp4

  
                        TRUNCATE TABLE #Temp4







                    END

					  TRUNCATE TABLE #Temp2








            END


        INSERT  INTO #Temp5
                ( ID ,
                  BOQID ,
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
                SELECT  ID ,
                        @BOQNEW ,
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
                FROM    dbo.BOQRateanalysisAllocationDetails
                WHERE   BOQID = @PREBOQID 

        INSERT  INTO dbo.BOQRateanalysisAllocationDetails
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
                SELECT  BOQID ,
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
                FROM    #Temp5


				INSERT INTO #Temp6
						   (ID,
						   RateHeaderId,
						   Cost,
						   CategoryId,
						   Percentage,
						   BoqId,ItemId)
					 Select A.ID, 	
						   A.RateHeaderId,
						   A.Cost, 
						   A.CategoryId,
						   A.Percentage, 
						   @BOQNEW,ItemId from [dbo].[CostProvisionSnapShot] A where A.boqId= @PREBOQID 
                    


					INSERT INTO [dbo].[CostProvisionSnapShot]
							   ([RateHeaderId]
							   ,[Cost]
							   ,[CategoryId]
							   ,[Percentage]
							   ,[BoqId],
								[ItemId])
						 Select
							   RateHeaderId,
							   Cost,
							   CategoryId, 
							   Percentage, 
							   BoqId,ItemId from #Temp6


							

				


COMMIT TRAN 
				END TRY
BEGIN CATCH
	SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH



    END

GO

