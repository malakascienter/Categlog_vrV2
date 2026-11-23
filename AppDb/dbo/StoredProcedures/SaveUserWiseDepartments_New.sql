-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 27 september 2023
-- Description:	New Save UserWiseDepartment SP

-- [dbo].[SaveUserWiseDepartments_New] '<ArrayOfAddUserWiseDepartmentsAndLocations xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><AddUserWiseDepartmentsAndLocations><Id>1</Id><UserId>4168</UserId><Code>1</Code><Name>BANQUET</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>2</Id><UserId>4168</UserId><Code>2</Code><Name>CHINESE RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>3</Id><UserId>4168</UserId><Code>3</Code><Name>JAPANESE RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>4</Id><UserId>4168</UserId><Code>4</Code><Name>THAI RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>5</Id><UserId>4168</UserId><Code>5</Code><Name>WESTERN RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>6</Id><UserId>4168</UserId><Code>6</Code><Name>INDIAN RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>7</Id><UserId>4168</UserId><Code>7</Code><Name>SRI LANKAN RESTAURANT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>8</Id><UserId>4168</UserId><Code>8</Code><Name>PASTRY SHOP</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>9</Id><UserId>4168</UserId><Code>9</Code><Name>PUB </Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>10</Id><UserId>4168</UserId><Code>10</Code><Name>ROOM </Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>11</Id><UserId>4168</UserId><Code>11</Code><Name>BANQUET KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>12</Id><UserId>4168</UserId><Code>12</Code><Name>CHINESE KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>13</Id><UserId>4168</UserId><Code>13</Code><Name>JAPANESE KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>14</Id><UserId>4168</UserId><Code>14</Code><Name>THAI KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>15</Id><UserId>4168</UserId><Code>15</Code><Name>WESTERN KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>16</Id><UserId>4168</UserId><Code>16</Code><Name>INDIAN KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>17</Id><UserId>4168</UserId><Code>17</Code><Name>SRI LANKAN KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>18</Id><UserId>4168</UserId><Code>18</Code><Name>PASTRY KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>19</Id><UserId>4168</UserId><Code>19</Code><Name>COLD KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>20</Id><UserId>4168</UserId><Code>20</Code><Name>HALAL KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>21</Id><UserId>4168</UserId><Code>21</Code><Name>STAFF KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>22</Id><UserId>4168</UserId><Code>22</Code><Name>ARTIST</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>23</Id><UserId>4168</UserId><Code>23</Code><Name>BUTCHERY</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>24</Id><UserId>4168</UserId><Code>24</Code><Name>PUB BAR</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>25</Id><UserId>4168</UserId><Code>25</Code><Name>BANQUET BAR</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>26</Id><UserId>4168</UserId><Code>26</Code><Name>SERVICE BAR</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>27</Id><UserId>4168</UserId><Code>27</Code><Name>ROOM SERVICE</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>28</Id><UserId>4168</UserId><Code>28</Code><Name>LINEN ROOM</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>29</Id><UserId>4168</UserId><Code>29</Code><Name>CORPORATE</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>30</Id><UserId>4168</UserId><Code>30</Code><Name>ADMINISTRATION</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>31</Id><UserId>4168</UserId><Code>31</Code><Name>FINANCE</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>32</Id><UserId>4168</UserId><Code>32</Code><Name>COST CONTROL</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>33</Id><UserId>4168</UserId><Code>33</Code><Name>INCOME AUDIT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>34</Id><UserId>4168</UserId><Code>34</Code><Name>STORES &amp; RECIVING</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>35</Id><UserId>4168</UserId><Code>35</Code><Name>HUMAN RESOURCES</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>36</Id><UserId>4168</UserId><Code>36</Code><Name>PROCUREMENT</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>37</Id><UserId>4168</UserId><Code>37</Code><Name>INFORMATION TECHNOLOGY</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>38</Id><UserId>4168</UserId><Code>38</Code><Name>FRONT OFFICE</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>39</Id><UserId>4168</UserId><Code>39</Code><Name>HOUSEKEEPING</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>40</Id><UserId>4168</UserId><Code>40</Code><Name>SALES AND MARKETING</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>41</Id><UserId>4168</UserId><Code>41</Code><Name>ENGINEERING</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>42</Id><UserId>4168</UserId><Code>42</Code><Name>SECURITY</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>43</Id><UserId>4168</UserId><Code>43</Code><Name>KITCHEN STEWARDING</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>45</Id><UserId>4168</UserId><Code>44</Code><Name>TTEST</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>46</Id><UserId>4168</UserId><Code>45</Code><Name>GRAND MONARCH</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>47</Id><UserId>4168</UserId><Code>46</Code><Name>DESSERT KITCHEN</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations><AddUserWiseDepartmentsAndLocations><Id>49</Id><UserId>4168</UserId><Code>ABC</Code><Name>TESTD</Name><IsActive>true</IsActive><CompanyName>Monarch Imperial (Pvt) Ltd</CompanyName><IsCheck>true</IsCheck><CompanyID>1</CompanyID><CreatedDate>2023-10-10T09:11:33.945Z</CreatedDate><CreatedUserId>4168</CreatedUserId></AddUserWiseDepartmentsAndLocations></ArrayOfAddUserWiseDepartmentsAndLocations>',1

-- =============================================
CREATE PROCEDURE [dbo].[SaveUserWiseDepartments_New] 
@XMLData AS XML,
@Action INT
	
AS
	DECLARE @iDocID INT 
	 DECLARE @ErrorMsg VARCHAR(300)
BEGIN
	BEGIN TRY
        BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;


		 
				SELECT  *
				INTO    #TEMPH
				FROM    OPENXML (@iDocID,'ArrayOfAddUserWiseDepartmentsAndLocations/AddUserWiseDepartmentsAndLocations',2)	
				WITH (Id int,UserId INT,Code VARCHAR(20) ,Name VARCHAR(50),IsActive BIT,CompanyName VARCHAR(MAX),IsCheck BIT,CompanyID INT,CreatedDate DATETIME,CreatedUserId INT)



				SELECT  '#TEMPH',*
				from    #TEMPH

				DECLARE @UserID INT, @CompanyID INT

				SELECT TOP(1)@UserID = UserId,@CompanyID = CompanyID
				FROM #TEMPH

				--set @UserID = 0
				
	IF(@Action = 1)
	BEGIN

	
				DELETE 
				FROM UserWiseDepartments
				WHERE userId = @UserID AND companyId = @CompanyID

				INSERT INTO dbo.UserWiseDepartments
							(
								userId,
								deptid,
								companyId,
								IPAddress,
								CreatedUserID,
								LastModUserID,
								CreatedDate,
								LastModDate
							)
							SELECT UserId,Id,CompanyID,'',CreatedUserId,CreatedUserId,SYSDATETIME(),SYSDATETIME() FROM #TEMPH WHERE IsCheck=1

				
							SELECT *
							FROM UserWiseDepartments
							WHERE userId = @UserID

						-----------------newly added 12.02.2024 ----------------------
			IF(@UserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured :User ID Invalid, Please Log In Again',16,1)

			ROLLBACK TRANSACTION

		END
-------------------------------------------------------------------
	END

	IF(@Action = 2)
	BEGIN

				DELETE 
				FROM UserWise_Location
				WHERE userId = @UserID AND CompanyId = @CompanyID

				INSERT INTO UserWise_Location(UserID, LocationID, CompanyId, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate)
				SELECT UserId,Id,CompanyID,IsActive,'',CreatedUserId,CreatedUserId,SYSDATETIME(),SYSDATETIME() FROM #TEMPH WHERE IsCheck=1


				---
				DECLARE @IsLocationWiseDepartment BIT

				SELECT @IsLocationWiseDepartment  = ISNULL(IsLocationWiseDepartment,0)
				FROM Companies;

				IF(@IsLocationWiseDepartment = 1)
				BEGIN
				
				DELETE UD
				FROM UserWiseDepartments UD
				INNER JOIN Departments DP ON UD.deptid = DP.ID
				WHERE userId = @UserID AND companyId = @CompanyID
				AND LocationID <>0

				INSERT INTO dbo.UserWiseDepartments
							(
								userId,
								deptid,
								companyId,
								IPAddress,
								CreatedUserID,
								LastModUserID,
								CreatedDate,
								LastModDate
							)
							SELECT TP.UserId,DP.Id,TP.CompanyID,'',TP.CreatedUserId,TP.CreatedUserId,SYSDATETIME(),SYSDATETIME() 
							FROM #TEMPH TP
							INNER JOIN Departments DP ON TP.ID = DP.LocationID
							WHERE TP.IsCheck=1
                END
				--------

				select * 
				FROM UserWise_Location
				WHERE userId = @UserID

										-----------------newly added 12.02.2024 ----------------------
		IF(@UserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured :User ID Invalid, Please Log In Again',16,1)

			ROLLBACK TRANSACTION

		END
-------------------------------------------------------------------


	END
				
       COMMIT TRAN  --Transaction Success!
    END TRY
    BEGIN CATCH
	    --RAISERROR('Error raised in TRY block.', 16, 1 )
     --   IF @@TRANCOUNT > 0
     --       ROLLBACK TRAN 
	    --SELECT  
     --       ERROR_NUMBER() AS ErrorNumber  
     --       ,ERROR_SEVERITY() AS ErrorSeverity  
     --       ,ERROR_STATE() AS ErrorState  
     --       ,ERROR_PROCEDURE() AS ErrorProcedure  
     --       ,ERROR_LINE() AS ErrorLine  
     --       ,ERROR_MESSAGE() AS ErrorMessage;  
	 

		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);


    END CATCH;



END

GO

