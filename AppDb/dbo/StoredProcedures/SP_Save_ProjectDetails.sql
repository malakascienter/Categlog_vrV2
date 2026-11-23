/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON5/18/2018 4:19:54 PM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
@status RETURNS 5 Cantdelete
@status RETURNS 6 DeleteSuccess
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/
CREATE PROCEDURE[dbo].[SP_Save_ProjectDetails]
 --DECLARE PARAMETERS

	@Id int,
	@ClientID int,
	@ProjectName nvarchar(200),
	@HaveBOQ bit,
	@ProjectManagerEmail nvarchar(100),
	@PlannedStartingDate datetime,
	@PlannedEndingDate datetime,
	@ActualStratingDate datetime,
	@ActualEndingDate datetime,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Projecstatus bit,
	@ProjectCode nvarchar(max),
	@ClientProjectManagerName nvarchar(max),
	@ClientProjectManagerPhone nvarchar(max),
	@ClientProjectManagerEmail nvarchar(max),
	@AdvanceRecoveryPercentage decimal(18, 2),
	@ProjectRetentionPercentage decimal(18, 2),
	@BillRetentionPercentage decimal(18, 2),
	@DefectLiabilityPeriod int,
	@RetentionReleaseAtCloser decimal(18, 2),
	@RetentionReleaseAtDefectPeriod decimal(18, 2),
	@Basecurrency decimal(18,2),
	@ExchangeRate int,
	@Action[int],
	@status[int] OUTPUT,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT,
	@Pcode NVARCHAR(max) OUTPUT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET @NewId = 0;
	SET @status = 0;
	SET @message = '';
	SET @Pcode = '';
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM ProjectDetails WHERE  [Id] = @Id OR ProjectName = @ProjectName )
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE ProjectDetails SET
		[ClientID] = @ClientID,
		[ProjectName] = @ProjectName,
		[HaveBOQ] = @HaveBOQ,
		[ProjectManagerEmail] = @ProjectManagerEmail,
		[PlannedStartingDate] = @PlannedStartingDate,
		[PlannedEndingDate] = @PlannedEndingDate,
		[ActualStratingDate] = @ActualStratingDate,
		[ActualEndingDate] = @ActualEndingDate,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate,
		[Projecstatus] = @Projecstatus,
		[ProjectCode] = @ProjectCode,
		[ClientProjectManagerName] = @ClientProjectManagerName,
		[ClientProjectManagerPhone] = @ClientProjectManagerPhone,
		[ClientProjectManagerEmail] = @ClientProjectManagerEmail,
		[AdvanceRecoveryPercentage] = @AdvanceRecoveryPercentage,
		[ProjectRetentionPercentage] = @ProjectRetentionPercentage,
		[BillRetentionPercentage] = @BillRetentionPercentage,
		[DefectLiabilityPeriod] = @DefectLiabilityPeriod,
		[RetentionReleaseAtCloser] = @RetentionReleaseAtCloser,
		[RetentionReleaseAtDefectPeriod] = @RetentionReleaseAtDefectPeriod,
		[Basecurrency]=@Basecurrency,
		[ExchangeRate]=@ExchangeRate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO ProjectDetails(
		[ClientID],
		[ProjectName],
		[HaveBOQ],
		[ProjectManagerEmail],
		[PlannedStartingDate],
		[PlannedEndingDate],
		[ActualStratingDate],
		[ActualEndingDate],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[Projecstatus],
		[ProjectCode],
		[ClientProjectManagerName],
		[ClientProjectManagerPhone],
		[ClientProjectManagerEmail],
		[AdvanceRecoveryPercentage],
		[ProjectRetentionPercentage],
		[BillRetentionPercentage],
		[DefectLiabilityPeriod],
		[RetentionReleaseAtCloser],
		[RetentionReleaseAtDefectPeriod],
		[Basecurrency],
		[ExchangeRate]
		)
		VALUES
		(
		@ClientID,
		@ProjectName,
		@HaveBOQ,
		@ProjectManagerEmail,
		@PlannedStartingDate,
		@PlannedEndingDate,
		@ActualStratingDate,
		@ActualEndingDate,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@Projecstatus,
		@ProjectCode,
		@ClientProjectManagerName,
		@ClientProjectManagerPhone,
		@ClientProjectManagerEmail,
		@AdvanceRecoveryPercentage,
		@ProjectRetentionPercentage,
		@BillRetentionPercentage,
		@DefectLiabilityPeriod,
		@RetentionReleaseAtCloser,
		@RetentionReleaseAtDefectPeriod,
		@Basecurrency,
		@ExchangeRate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @statusIN = 1;

		SET @Pcode = 'P00' + CONVERT(NVARCHAR(max), SCOPE_IDENTITY());
		PRINT @Pcode

		UPDATE dbo.ProjectDetails SET ProjectCode = @Pcode WHERE Id = SCOPE_IDENTITY()

	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		
	DECLARE @Ishave BIT 


    IF(( (SELECT Count(*) 
          FROM   dbo.projectdetails 
          WHERE  EXISTS (SELECT * 
                         FROM   dbo.billheaders 
                         WHERE  projectid = @Id)) > 0 )) 
      BEGIN 
          SET @Ishave = 'true' 		  
      END 

    IF( @Ishave = 'true' ) 
      BEGIN 
          PRINT 'have' 
		  SET @status = 5 --can't delete
      END 
    ELSE 
      BEGIN 
          CREATE TABLE #tempprojectdetails 
            ( 
               id                             INT, 
               clientid                       INT, 
               projectname                    NVARCHAR(200), 
               haveboq                        BIT, 
               projectmanageremail            NVARCHAR(100), 
               plannedstartingdate            DATETIME, 
               plannedendingdate              DATETIME, 
               actualstratingdate             DATETIME, 
               actualendingdate               DATETIME, 
               ipaddress                      NVARCHAR(max), 
               createduserid                  INT, 
               lastmoduserid                  INT, 
               createddate                    DATETIME, 
               lastmoddate                    DATETIME, 
               projecstatus                   BIT, 
               projectcode                    NVARCHAR(max), 
               clientprojectmanagername       NVARCHAR(max), 
               clientprojectmanagerphone      NVARCHAR(max), 
               clientprojectmanageremail      NVARCHAR(max), 
               advancerecoverypercentage      DECIMAL, 
               projectretentionpercentage     DECIMAL, 
               billretentionpercentage        DECIMAL, 
               defectliabilityperiod          INT, 
               retentionreleaseatcloser       DECIMAL, 
               retentionreleaseatdefectperiod DECIMAL,
			   Basecurrency                   INT,
		       ExchangeRate                   DECIMAL    
            ) 

          INSERT INTO #tempprojectdetails 
                      (id, 
                       clientid, 
                       projectname, 
                       haveboq, 
                       projectmanageremail, 
                       plannedstartingdate, 
                       plannedendingdate, 
                       actualstratingdate, 
                       actualendingdate, 
                       ipaddress, 
                       createduserid, 
                       lastmoduserid, 
                       createddate, 
                       lastmoddate, 
                       projecstatus, 
                       projectcode, 
                       clientprojectmanagername, 
                       clientprojectmanagerphone, 
                       clientprojectmanageremail, 
                       advancerecoverypercentage, 
                       projectretentionpercentage, 
                       billretentionpercentage, 
                       defectliabilityperiod, 
                       retentionreleaseatcloser, 
                       retentionreleaseatdefectperiod,
					   Basecurrency,
		               ExchangeRate) 
          SELECT * 
          FROM   dbo.projectdetails 
          WHERE  id = @Id

          DELETE projectdetails 
          WHERE  id = @Id 
		  SET @status = 6 --delete
      END 

	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	IF(@status != 6 and @status != 5)
	BEGIN
	SET @status = @statusIN
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	SET @status = -1;
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH
END--SP ENDS

GO

