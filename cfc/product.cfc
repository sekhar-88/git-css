<cfcomponent>
    <cffunction name="user_checkout" returntype="boolean" returnformat="json" output="true" access="remote">
        <cfargument name="pid" type="numeric" required="true" />
          <cfset addedToCart = addToCart(arguments.pid)/>
          <cfif addedToCart>
              <!--- <cfdump var="#addedToCart#" /> --->
          </cfif>
          <cfreturn #addedToCart#/>
    </cffunction>

    <cffunction name = "addToCart" returnType = "boolean" returnFormat="json" access = "remote" output="false">
        <cfargument name="pid" type="numeric" required="true" />

            <cfif session.loggedin>
                <cfset userid = #session.User.UserId# />
                <!--- is product already in cart --->
                <cfquery name="cart">
                    select *
                    from [Cart]
                    Where ProductId= #arguments.pid# AND UserId = #userid#
                </cfquery>

                <cfif cart.recordCount>  <!--- in cart --->
                    <cfreturn true/>  <!--- THIS RETURN TRUE IS FOR sending (buynow) button that it is already in cart --->
                <cfelse>                      <!--- not in cart --->
                    <cfquery name="insetToCart">
                        INSERT INTO [Cart]
                        (ProductId,Qty,UserId)
                        VALUES
                        (<cfqueryparam value="#arguments.pid#" cfsqltype="cf_sql_integer">, 1, #userid#)
                    </cfquery>
                    <!--- cart data changed --->
                    <cfset session.cartDataChanged = true/>;
                    <cfreturn true />
                </cfif>

            <cfelse>  <!---not logged in  ADD TO Session Cart--->
                <cfif ArrayContains(session.cart, #arguments.pid#)>
                    <cfreturn false/>
                <cfelse>
                    <cfset ArrayAppend(session.cart, #arguments.pid#) /> <!--- Store in Session --->
                    <cfset session.cartDataChanged = true/>
                    <cfreturn true />
                </cfif>
            </cfif>
    </cffunction>

    <cffunction name="getProductsForSubCat" access="remote" returntype="Query" output = "false" >
        <cfargument name="scat" required="true" type="numeric" output="false" />
        <cfquery name="products" >
            SELECT *
            FROM [Product]
            WHERE SubCategoryId = <cfqueryparam value = "#arguments.scat#" CFSQLType = "[cf_sql_integer]">
        </cfquery>
        <cfreturn #products#/>
    </cffunction>

</cfcomponent>
