

/*

SaveBOQAMDDate '<BOQAmendmentHeader><BOQID>29</BOQID><Remark>added</Remark><IPAddress>192.168.1.2</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-07-25T09:53:48.743Z</CreatedDate><LastModDate>2019-07-25T09:53:48.743Z</LastModDate><ProjectID>2</ProjectID><DocumentNo> </DocumentNo><Approve>false</Approve><ApprovedUserId>-1</ApprovedUserId><ApprovedDate>2019-07-25T09:53:48.743Z</ApprovedDate><BOQAMDdetails><BOQAmendmentDetails><ItemID>225</ItemID><BalanceQTY>4</BalanceQTY><BOQAMDheaderID>-1</BOQAMDheaderID></BOQAmendmentDetails></BOQAMDdetails></BOQAmendmentHeader>',1,5," ",1

*/

CREATE procedure [dbo].[SaveBOQAMDDate] 
 @XMLDetails  XML,
 @PropertyID INT,
 @LocationID INT,
 @docID varchar(max) output,
 @Recipientheaderid INT output
AS

Begin

	BEGIN TRY
         BEGIN TRANSACTION
	     
		 	 DECLARE @iDocID INT 
		       EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

				declare @RequestType varchar(2),@TransactionTypeID INT,@DepartmentID int,@DocumentNo varchar(max),@BOQAMDHeaderID INT

			
			   SELECT  *
				INTO    #TEMP1
				FROM    OPENXML (@iDocID,'BOQAmendmentHeader',2)	
				WITH (BOQID INT, Remark varchar(max),IPAddress varchar(max),CreatedUserID INT,DepartmentID INT,LocationID INT,LastModUserID INT,ProjectID INT,Approve BIT,DocumentNo varchar(max),ApprovedUserId INT,ApprovedDate Date)
				

					--get the template details
				Select *
				INTO #Temp2
				FROM    OPENXML (@iDocID,'BOQAmendmentHeader/BOQAMDdetails/BOQAmendmentDetails',2)
				With (ItemID INT,BalanceQTY Decimal,BOQAMDheaderID INT)



SET @RequestType='BA'
select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@RequestType)

IF @DocumentNo IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@RequestType,1,6)
END

select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@RequestType)
SELECT @DocumentNo='BA'+@DocumentNo

update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@RequestType



INSERT INTO [dbo].[BOQAmendmentHeader]
           ([BOQId]
           ,[Remark]   
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate]
		   ,[ProjectId]
		   ,[DocumentNo]
		   ,[Approve]
		   ,[ApprovedUserId]
		   ,[ApprovedDate]
		   ,[LocationID],
		    [DepartmentID]
		   )
     Select
           BOQId,
           Remark,
           IPAddress,
           CreatedUserID, 
           LastModUserID,
           GETDATE(),
		   GETDATE(),
		   ProjectId,
		   @DocumentNo,
		   Approve,
		   ApprovedUserId,
		   GETDATE(),
		   LocationID,
		   DepartmentID
		   from #TEMP1

set @BOQAMDHeaderID= SCOPE_IDENTITY()
set @Recipientheaderid = SCOPE_IDENTITY()
set @docID=@DocumentNo


INSERT INTO [dbo].[BOQAmedmentDetails]
           ([ItemID]
           ,[BalanceQTY]
           ,[BOQAMDheaderID])
     select
           ItemID,
           BalanceQTY,
		   SCOPE_IDENTITY()
		   from #TEMP2

		SELECT  @TransactionTypeID = Id
        FROM    TransactionTypes
        WHERE   Code = 'BA'

		    EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID,@LocationID,
            @TransactionTypeID,@BOQAMDHeaderID

		   select 1

		 COMMIT TRANSACTION


	END TRY
		BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





END

GO

