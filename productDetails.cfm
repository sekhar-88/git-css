<cfset productCFC = createObject("cfc.product")/>

<!DOCTYPE html>
<html>
<head>
    <link href="assets/css/productDetail.css" rel="stylesheet">
    <script src="assets/js/productDetail.js"></script>
    <cfinclude template = "assets/libraries/libraries.cfm">


    <script>
    </script>
</head>
<body>

<div id="header"><cfinclude template = "commons/header.cfm" /></div>

<!---   [to be designed] / [WORKED UPON]
.product_details_pd_container
    pd_image
        pd_image-thumbnails
        pd_image-preview
    pd_info
        pd_name
        pd_price
        pd_description
        pd_specification

.featured_product_fp_container
    fp_products carousel
        .fp_product
            .fp_image
            .fp_name
            .fp_price
--->

    <div class="container-fluid">
    <cfif StructKeyExists(URL, "pid")>
        <cfset pd = productDetails = productCFC.fetchProductDetails(url.pid)/>

        <cfif productdetails.recordCount> <!--- Product Exists --->
            <cfoutput>
                    <div class="pd-image-container">
                        <img src="assets/images/products/medium/#productDetails.Image#" alt="">
                    </div>


            <div class="pd-info-container">
                <div id="pdi-name">
                    #productDetails.BrandName# - #productDetails.Name# #productDetails.ListPrice#
                </div>

                <div id="pdi-buttons">
                    <!--- check for if already in cart  --->
                        <cfset incart = productCFC.isProductInCart(#URL.pid#)/>
                        <cfif incart>
                            <span id="gotocart_btn">    <!--- Show Go To Cart button --->
                            <button type="button" value="##" onclick="window.location.href='cart.cfm';" class="btn btn-primary verdana"><span class="glyphicon glyphicon"></span> Go To Cart</button>
                            </span>
                        <cfelse>
                            <span id="addtocart_btn">  <!--- Show Add to cart  button --->
                            <button type="button" value="#pid#" onclick="addToCart(this);changeto_gotocart();" class="btn btn-primary verdana"><span class="glyphicon glyphicon-shopping-cart"></span> Add to Cart</button>
                            </span>
                        </cfif>                         <!--- Show Buy Now Button --->

                    <cfif session.loggedin>
                        <button type="button" value="#pid#" onclick="checkOut(this,#session.user.userid#);" class="btn btn-success verdana"><span class="glyphicon glyphicon-usd"></span> Buy Now</button>
                    <cfelse>
                        <button type="button" value="#pid#" onclick="notify('Login to Continue..');showLoginMsg();" class="btn btn-success verdana"><span class="glyphicon glyphicon-usd"></span> Buy Now</button>
                        <span class="hidden well login-notify">Please <a href="##" data-toggle="dropdown" data-target = ".login_toggle">login</a> to continue.</span>
                    </cfif>
                </div>
            </div>


            </cfoutput>
        <cfelse>  <!--- Product Not found for the provided pID --->
            <h3 class="text text-danger">Error Getting Product Details</h3>
        </cfif>
    <cfelse>
        <cflocation url = "index.cfm" addToken="false">
    </cfif>
    </div>

<cfinclude template = "commons/footer.cfm">
</body>
</html>
