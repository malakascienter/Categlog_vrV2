
--SP_WRD_CalWDRPossibleValue 216377.04,2,2,4,3,5,-1
CREATE PROCEDURE [dbo].[SP_WRD_CalWDRPossibleValue]
    @Value DECIMAL,
    @BOQID INT,
    @MainWorkID INT,
    @WorkID INT,
    @ProjectID INT,
    @DepartmentID INT,
    @OUTVAL INT OUTPUT,
    @OUTVALPOS DECIMAL OUTPUT
AS
BEGIN

    DECLARE @TotalVal DECIMAL,
            @WorkVal DECIMAL,
            @NewToalVal DECIMAL,
            @Outval2 DECIMAL;


    IF (
       (
           SELECT COUNT(Id)
           FROM dbo.WorkDoneRegistries
           WHERE ProjectID = @ProjectID
                 AND DepartmentID = @DepartmentID
                 AND BOQID = @BOQID
                 AND MainWorkID = @MainWorkID
                 AND WorkID = @WorkID
       ) > 0
       )


	   BEGIN
        SELECT @TotalVal = SUM(Value)
        FROM dbo.WorkDoneRegistries
        WHERE ProjectID = @ProjectID
              AND DepartmentID = @DepartmentID
              AND BOQID = @BOQID
              AND MainWorkID = @MainWorkID
              AND WorkID = @WorkID;

    SELECT @WorkVal = WorkValue
    FROM dbo.WorkDoneRegistries
    WHERE ProjectID = @ProjectID
          AND DepartmentID = @DepartmentID
          AND BOQID = @BOQID
          AND MainWorkID = @MainWorkID
          AND WorkID = @WorkID;

    SET @NewToalVal = @TotalVal + @Value;



    IF (@NewToalVal > @WorkVal)
    BEGIN

        SET @Outval2 = 0;

    END;
    ELSE
    BEGIN

        SET @Outval2 = 1;

    END;

    SET @OUTVAL = @Outval2;
    SET @OUTVALPOS = @WorkVal - @TotalVal;
	
	END
	ELSE
    
	BEGIN

	SET @OUTVAL=2
	SET @OUTVALPOS =0
	END

    SELECT 1;
	
END;

GO

