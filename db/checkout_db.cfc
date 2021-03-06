<!---
    Component Name: checkout_db.cfc
    This Model Contains DATABASE Operations done on CHECKOUT Page functionality
--->

<cfcomponent>

    <cffunction name="getAddressForUser" returntype="query" access="public" >
        <cftry >

            <cfquery name="LOCAL.addresses">
                SELECT AddressId, UserId, Name, AddressLine, PhoneNo, PostalCode, State, City, Country, AddressType, LandMark
                FROM [Address]
                WHERE UserId = #SESSION.user.userid# AND Status IS NULL
            </cfquery>

            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
                <cfdump var="#cfcatch#" />
            </cfcatch>
        </cftry>

        <cfreturn #LOCAL.addresses# />
    </cffunction>


    <cffunction name="queryOrderSummary" returntype="query" access = "public" >

        <cfquery name="LOCAL.itemsQuery">
            SELECT c.CartId, c.ProductId, c.Qty , p.Name, p.ListPrice , p.DiscountedPrice, p.Description, p.Image
            from [Cart] c
            inner join [Product] p
            ON c.ProductId = p.ProductId
            Where c.UserId = <cfqueryparam value="#SESSION.User.UserId#" cfsqltype="cf_sql_bigint" />
        </cfquery>

        <cfreturn LOCAL.itemsQuery />
    </cffunction>


    <cffunction name="insertNewAddress" returntype = "boolean" access = "public" >
        <cfargument name="AddressLine" type="string" required="true" >
        <cfargument name="Name"        type="string" required="true" >
        <cfargument name="LandMark"    type="string" required="true" >
        <cfargument name="PhoneNo"     type="string" required="true" >
        <cfargument name="PostalCode"  type="string" required="true" >

        <cftry >
            <cfquery >
                INSERT INTO [Address]
                (UserId,AddressLine,Name,LandMark,PhoneNo,PostalCode,Country,AddressType)
                VALUES
                (   #session.User.UserId#,
                    <cfqueryparam value="#ARGUMENTS.AddressLine#" cfsqltype="CF_SQL_NVARCHAR" >,
                    <cfqueryparam value="#ARGUMENTS.Name#"        cfsqltype="CF_SQL_NVARCHAR" >,
                    <cfqueryparam value="#ARGUMENTS.LandMark#"    cfsqltype="CF_SQL_NVARCHAR" >,
                    <cfqueryparam value="#ARGUMENTS.PhoneNo#"     cfsqltype="CF_SQL_NVARCHAR" >,
                    <cfqueryparam value="#ARGUMENTS.PostalCode#"  cfsqltype="CF_SQL_NVARCHAR" >,
                    'India',
                    0
                )
            </cfquery>
            <cfset LOCAL.response = true >

            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
                <cfset LOCAL.response = false />
            </cfcatch>
        </cftry>

        <cfreturn LOCAL.response />
    </cffunction>

<!---
    DELETE THE ADDRESS
    SET THE ADDRESS table's STATUS COLUMN AS DELETED
 --->
    <cffunction name="deleteAddress" returntype="boolean" access="public"  >
        <cfargument name="addressid" required="true" type="numeric" />
        <cfset LOCAL.response = false />

        <cftry>

            <cfquery name="deleteAddress">
                UPDATE [Address]
                SET Status = 'deleted'
                WHERE AddressId = <cfqueryparam value="#arguments.addressid#" cfsqltype="CF_SQL_BIGINT"  />
            </cfquery>
            <cfset LOCAL.response = true />

            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
                <cfset LOCAL.response = false />
            </cfcatch>

        </cftry>

        <cfreturn true />
    </cffunction>


<!---can't update address for showing order history purpose
    so this function may not be used
--->
    <cffunction name="updateAddress" returntype = "boolean" access="public" >
        <cfargument name="addressStruct" type="struct" required = "true" />
        <cfargument name="addressid" required="true" type="numeric" />

        <cftry >

            <cfquery name = "updateAddress">                    <!--- start updaing the address of the corresponding User --->
                <cfloop collection="#ARGUMENTS.addressStruct#" item="item" >
                    update [Address]
                    set #item# = <cfqueryparam value="#ARGUMENTS.addressStruct[item]#" cfsqltype="cf_sql_nvarchar" />
                    where AddressId = <cfqueryparam value="#arguments.addressid#" cfsqltype="cf_sql_bigint" />
                </cfloop>
                    update [Address]
                    set UserId = #session.User.UserId#,
                        AddressType = 0
                        where AddressId = <cfqueryparam value="#arguments.addressid#" cfsqltype="cf_sql_bigint" />
            </cfquery>
            <cfset LOCAL.response = true >

            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
                <cfset LOCAL.response = true />
            </cfcatch>

        </cftry>

        <cfreturn LOCAL.response />
    </cffunction>


<!--- returns TOTAL COST of products in USER / Session Cart --->
    <cffunction name="getCartTotal" returntype="numeric" access="public">
        <cfset LOCAL.sumTotal = 0>

        <cfif SESSION.loggedin>

            <cfquery name="LOCAL.cartPrices">
                SELECT TotalPrice
                from [Cart]
                Where UserId = #session.User.UserId#
            </cfquery>

            <cfloop query="LOCAL.cartPrices" >
                <cfset LOCAL.sumTotal += #TotalPrice# />
            </cfloop>

        <cfelse>

            <cfset LOCAL.sumTotal = -1 />
        </cfif>


        <cfreturn LOCAL.sumTotal />
    </cffunction>



    <cffunction name="clearCart" returntype="boolean" access = "public" >

        <cfquery name="clearCart">
            DELETE FROM [Cart]
            WHERE UserId = #session.User.UserId#
        </cfquery>
        <cfreturn true/>
    </cffunction>

    <cffunction name="updateCartAndTotalPrice" returntype="boolean" access = "public"  >
        <cfargument name="cartid" required="true" type="numeric"    />
        <cfargument name="pid" required="true" type="numeric"       />
        <cfargument name="qty" required="true" type="numeric"        />
        <cfargument name="totalPrice" required="true" type="numeric" />

        <cfquery>
            UPDATE [Cart]
            SET Qty = <cfqueryparam value="#arguments.qty#" cfsqltype="cf_sql_int" />,
                TotalPrice = <cfqueryparam value="#totalPrice#" cfsqltype="cf_sql_bigint" />
            WHERE CartId = <cfqueryparam value="#arguments.cartid#" cfsqltype="cf_sql_bigint" />
        </cfquery>

        <cfreturn true/>
    </cffunction>





    <cffunction name="getProductsDetailFromCart" returntype="query" access = "public" >

        <cfquery name="LOCAL.cartItemDetails"> <!--- \/ & OrderId, ShipToAddressId --->
            SELECT c.ProductId, p.ListPrice AS UnitPrice, c.Qty AS OrderQty, p.SupplierId
            FROM [Cart] c

            inner join [Product] p
            on c.ProductId = p.ProductId

            WHERE c.UserId = #SESSION.User.UserId#
        </cfquery>

        <cfreturn #LOCAL.cartItemDetails# />
    </cffunction>

    <cffunction name="insertToOrderTable" returntype="struct" access = "public">

        <cfset LOCAL.subTotal = getCartTotal()/>

        <cfquery name="LOCAL.insertToOrderTable" result="LOCAL.insertedOrder">
            INSERT INTO [Order]
            (UserId, SubTotal, OrderDate, PaymentMethod, Status)
            VALUES
            (#SESSION.User.UserId#, #LOCAL.subTotal#, GETDATE(), 'COD', 'Processing')
        </cfquery>

        <cfreturn #LOCAL.insertedOrder# />
    </cffunction>


<!--- its first argument value getProductsDetailFromCart()
        which is a query containing the necessary items for inserting into the orderDetails table

        second argument depends on insertToOrderTable() query
        which gets the order ID from the 'resulted structure' from the inesrting query to Order table.
--->
    <cffunction name="insertToOrderDetails" returntype="void" access="public" >
        <cfargument name="cartItemDetails" type="query" required = "true" />
        <cfargument name="orderId" type="numeric" required = "true" />

        <cftry>

        <cfquery>
            <cfloop query="ARGUMENTS.cartItemDetails" >
                INSERT INTO [OrderDetails]
                (OrderId, ProductId, OrderQty, UnitPrice, SupplierId, ShipToAddressId)
                VALUES
                (
                    #ARGUMENTS.OrderId#,
                    #ARGUMENTS.cartItemDetails.ProductId#,
                    #ARGUMENTS.cartItemDetails.OrderQty#,
                    #ARGUMENTS.cartItemDetails.UnitPrice#,
                    #ARGUMENTS.cartItemDetails.SupplierId#,
                    #SESSION.User.checkout.AddressId#
                )
            </cfloop>
        </cfquery>


            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
                <cfset LOCAL.response.message = "Error while inserting In Order Details Table" />
            </cfcatch>
        </cftry>
    </cffunction>


    <cffunction name="getShippingDetails" returntype="Query" access= "public" >
        <cftry>
            <cfquery name="LOCAL.shippingAddress">
                SELECT AddressLine, City, PostalCode, PhonoNo
                FROM [Address]
                WHERE AddressId = #SESSION.User.checkout.AddressId#
            </cfquery>

            <cfcatch type="DATABASE">
                <cflog file = "ShoppingDBlog" text="message: #cfcatch.message# , NativeErrorCode: #cfcatch.nativeErrorCode#" type="error"  />
            </cfcatch>
        </cftry>

        <cfreturn LOCAL.shippingAddress />
    </cffunction>

</cfcomponent>
