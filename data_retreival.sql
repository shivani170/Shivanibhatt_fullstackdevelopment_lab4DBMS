-- 4) Display the total number of customers based on gender who have placed individual orders of worth at least Rs.3000.

SELECT CUS_GENDER, COUNT(DISTINCT CUS_ID) as TotalCustomers
FROM Order O
JOIN Customer C ON O.CUS_ID = C.CUS_ID
WHERE O.ORD_AMOUNT >= 3000
GROUP BY CUS_GENDER;

--5) Display all the orders along with product name ordered by a customer having Customer_Id=2
SELECT O.ORD_ID, O.ORD_AMOUNT, O.ORD_DATE, P.PRO_NAME
FROM Order O
JOIN Supplier_Pricing SP ON O.PRICING_ID = SP.PRICING_ID
JOIN Product P ON SP.PRO_ID = P.PRO_ID
WHERE O.CUS_ID = 2;


-- 6)Display the Supplier details who can supply more than one product.
SELECT S.*
FROM Supplier S
JOIN Supplier_Pricing SP ON S.SUPP_ID = SP.SUPP_ID
GROUP BY S.SUPP_ID, S.SUPP_NAME, S.SUPP_CITY, S.SUPP_PHONE
HAVING COUNT(SP.PRO_ID) > 1;


-- 7)  Find the least expensive product from each category and print the table with category id, name, product name and price of the produc
WITH LeastExpensiveProducts AS (
    SELECT
        C.CAT_ID,
        C.CAT_NAME,
        P.PRO_NAME,
        SP.SUPP_PRICE,
        ROW_NUMBER() OVER (PARTITION BY C.CAT_ID ORDER BY SP.SUPP_PRICE) AS RowNum
    FROM
        Category C
        JOIN Product P ON C.CAT_ID = P.CAT_ID
        JOIN Supplier_Pricing SP ON P.PRO_ID = SP.PRO_ID
)
SELECT
    CAT_ID,
    CAT_NAME,
    PRO_NAME AS LeastExpensiveProduct,
    SUPP_PRICE AS Price
FROM
    LeastExpensiveProducts
WHERE
    RowNum = 1;


--8)  Display the Id and Name of the Product ordered after “2021-10-05”.
SELECT P.PRO_ID, P.PRO_NAME
FROM Product P
JOIN Supplier_Pricing SP ON P.PRO_ID = SP.PRO_ID
JOIN Order O ON SP.PRICING_ID = O.PRICING_ID
WHERE O.ORD_DATE > '2021-10-05';

-- 9) Display customer name and gender whose names start or end with character 'A'.
SELECT CUS_NAME, CUS_GENDER
FROM Customer
WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

-- 10) Create a stored procedure to display supplier id, name, Rating(Average rating of all the products sold by every customer) and
-- Type_of_Service. For Type_of_Service, If rating =5, print “Excellent Service”,If rating >4 print “Good Service”, If rating >2 print “Average
-- Service” else print “Poor Service”. Note that there should be one rating per supplier

CREATE PROCEDURE DisplaySupplierInfo()
BEGIN
    SELECT
        S.SUPP_ID,
        S.SUPP_NAME,
        AVG(R.RAT_RATSTARS) AS Rating,
        CASE
            WHEN AVG(R.RAT_RATSTARS) = 5 THEN 'Excellent Service'
            WHEN AVG(R.RAT_RATSTARS) > 4 THEN 'Good Service'
            WHEN AVG(R.RAT_RATSTARS) > 2 THEN 'Average Service'
            ELSE 'Poor Service'
        END AS Type_of_Service
    FROM
        Supplier S
        JOIN Supplier_Pricing SP ON S.SUPP_ID = SP.SUPP_ID
        JOIN Order O ON SP.PRICING_ID = O.PRICING_ID
        LEFT JOIN Rating R ON O.ORD_ID = R.ORD_ID
    GROUP BY
        S.SUPP_ID, S.SUPP_NAME;
END //

DELIMITER ;