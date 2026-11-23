--[dbo].[Sp_delete_projectdetails] 10,1
CREATE PROCEDURE [dbo].[SP_Delete_ProjectDetails] @ProjectID INT, 
                                                 @IsDelete  BIT output 
AS 
    DECLARE @Ishave BIT 

    SET @IsDelete = 'true'; 

    IF(( (SELECT Count(*) 
          FROM   dbo.projectdetails 
          WHERE  EXISTS (SELECT * 
                         FROM   dbo.billheaders 
                         WHERE  projectid = @ProjectID)) > 0 )) 
      BEGIN 
          SET @Ishave = 'true' 
      END 

    IF( @Ishave = 'true' ) 
      BEGIN 
          PRINT 'have' 

          SET @IsDelete = 'false'; 
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
               retentionreleaseatdefectperiod DECIMAL 
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
                       retentionreleaseatdefectperiod) 
          SELECT * 
          FROM   dbo.projectdetails 
          WHERE  id = @ProjectID 
		  
		  DELETE ProjectDetails WHERE id = @ProjectID

          PRINT @IsDelete 
      END

GO

