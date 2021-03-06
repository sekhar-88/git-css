<!---
    == PRODUCT DETAILS PAGE ==
    this page shows detils of a product
    along with its informations ..
    ADMIN can update the product details info.
--->

<cfset VARIABLES.productCFC = createObject("cfc.product")/>

<!DOCTYPE html>
<html>
<head>
     <title>eShopping</title>
      <link href="../assets/css/productDetail.css" rel="stylesheet">
</head>
<body>

    <div class="page-header"><cfinclude template = "/commons/header.cfm" /></div>
    <!--- page refresh logic --->
    <input type="hidden" id="refreshed" value="no" />



        <!--- page body --->
    <div class="container-fluid page container-fluid-page">
        <cfif StructKeyExists(URL, "pid") AND IsNumeric(URL.pid)>
        <cfset VARIABLES.productDetails = VARIABLES.productCFC.fetchProductDetails(URL.pid) />

          <cfif VARIABLES.productdetails.recordCount> <!--- Product Exists --->
              <cfoutput>

                  <div class="pd-container">
                    <div class="image-view">
                        <div class="image-container-lg" style="background-image: url('../assets/images/products/medium/#VARIABLES.productDetails.Image#');">
                            <!--- <img src="../assets/images/products/medium/#VARIABLES.productDetails.Image#" alt=""> --->
                        </div>
                        <div id="buttons-container">
                              <cfif NOT isNULL(VARIABLES.productDetails.DiscontinuedDate)>
                                <!--- check for if already in cart  --->
                                  <cfset VARIABLES.incart = VARIABLES.productCFC.isProductInCart(#URL.pid#)/>

                                  <cfif VARIABLES.incart>
                                      <div id="gotocart_btn">    <!--- Show Go To Cart button --->
                                          <button type="button" value="##" onclick="window.location.href='cart.cfm';" class="btn btn-lg btn-primary verdana btn-radius-1"><span class="glyphicon glyphicon"></span> Go To Cart</button>
                                      </div>
                                  <cfelse>
                                      <div id="addtocart_btn">  <!--- Show Add to cart  button --->
                                          <button type="button" value="#URL.pid#" onclick="addToCart(this);changeto_gotocart();" class="btn btn-lg btn-primary verdana btn-radius-1"><span class="glyphicon glyphicon-shopping-cart"></span> Add to Cart</button>
                                      </div>
                                  </cfif>                         <!--- Show Buy Now Button --->

                                  <cfif session.loggedin>
                                      <div>
                                          <button type="button" value="#URL.pid#" onclick="checkOut(this,#session.user.userid#);" class="btn btn-lg btn-success verdana btn-radius-1"><span class="glyphicon glyphicon-usd"></span> Buy Now</button>
                                      </div>
                                  <cfelse>
                                      <div>
                                          <button type="button" value="#URL.pid#" onclick="showLoginMsg();" class="btn btn-lg btn-success verdana btn-radius-1"><span class="glyphicon glyphicon-usd"></span> Buy Now</button>
                                      </div>
                                  </cfif>
                              <cfelse>
                              </cfif>
                        </div>   <!--- end .pdi-buttons --->

                        <div class="well well-sm login-notify" style="display:none;">
                            <h4>Please <a href="##" data-toggle="dropdown" data-target = ".login_toggle">login</a> to continue.</h4>
                        </div>
                    </div>   <!--- end  .image-view --->


<!---
    [ProductId] ,[Name] ,[BrandId] ,[SubCategoryId] ,[Weight] ,[ListPrice] ,[SupplierId] ,[DiscontinuedDate] ,
    [DiscountPercent] ,[DiscountedPrice] ,[Qty] ,[Description] ,[Image]
 --->
                    <div class="product-details">
                        <cfif structKeyExists(Session.User, "Role") AND SESSION.User.Role EQ 'admin'>
                            <div class="buttons-admin" style="float: right;">
                                <button class="btn btn-warning" onclick="showUpdateModal(#VARIABLES.productDetails.ProductId#);" ><span class="fa fa-pencil"></span> Update</button>
                                <button class="btn btn-danger" onclick="deleteProduct(#VARIABLES.productDetails.ProductId#)"><span class="fa fa-trash"> </span> Delete</button>
                            </div>
                        </cfif>

                        <cfsavecontent variable="productDetailsHTML" >
                            <cfset categoryDetails = VARIABLES.productCFC.getSCategoryDetailsForProductId(URL.pid) />
                            <div class="category-details">#categoryDetails.CategoryName# &gt; <a href="product.cfm?cat=#categoryDetails.CategoryId#&amp;scat=#categoryDetails.SubCategoryId#">#categoryDetails.SubCategoryName#</a></div>
                            <div class="pd-name">
                                #productDetails.Name#
                            </div>
                            <div class="pd-rating">
                                <span class="badge">4</span>
                            </div>
                            <div class="pd-price">
                                <span></span><span>#productDetails.ListPrice#</span>
                            </div>
                            <div class="product-specification">
                                <div class="ps-header">Specifications: </div>
                                <div class="ps-content">
                                    <div class="ps-content-header"></div>
                                        <ul>
                                            <cfloop index="i" list="#productDetails.Description#" delimiters="`"  >
                                                <li>#i#</li>
                                            </cfloop>
                                        </ul>
                                </div>
                            </div>
                        </cfsavecontent>
                        #productDetailsHTML#
                    </div>
                </div>  <!-- end  ".pd-container"  product detials view (image & details section)-->

                <!--- show similar products --->
                <span class="clearfix"></span>

                    <div class = "similar-products-div"  style="margin-top: 50px;">
                        <!--- header --->
                        <div><h3 class="text-capitalize" style="padding: 10px;">similar products</h3></div>
                        <div class = "similar-inner-div" >

                            <cfset VARIABLES.similarProducts = VARIABLES.productCFC.getSimilarProducts(#URL.scat#, #URL.pid#) >
                                <cfloop query="#VARIABLES.similarproducts#" >
                                    <cfoutput>

                                        <cfset VARIABLES.similars = VARIABLES.productCFC.fetchProductDetails(#VARIABLES.similarProducts.ProductID#)/>
                                        <div class="similar-product">
                                            <a href="productDetails.cfm?scat=#VARIABLES.similars.SubCategoryId#&pid=#VARIABLES.similars.ProductID#"></a>
                                            <div class="similar-product-image" style=" background-image: url('../assets/images/products/medium/#VARIABLES.similars.Image#');"></div>
                                            <p style="color:black;">#VARIABLES.similars.Name#</p>
                                            <h5 align = "center"><span class="inr"></span><span class="similar-product-price">#VARIABLES.similars.ListPrice#</span><h5>
                                        </div>

                                    </cfoutput>
                                </cfloop>

                        </div>
                    </div>


                    <!---
                        MODAL FOR UPDATING THE PRODUCT DETAILS
                    --->
                    <form class="" action="" enctype="multipart/form-data" method="post" id="product-update-form" name="product-update-form">
                        <div class="modal fade" tabindex="-1" role="dialog" id="update-product-modal">
                          <div class="modal-dialog" role="document" style="width: 450px;">
                            <div class="modal-content" style="-webkit-border-radius: 0px !important;-moz-border-radius: 0px !important;border-radius: 0px !important;">

                              <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                <h3 align="center" class="modal-title">Update Product</h3>
                              </div>

                              <div class="modal-body">
                                  <cfoutput>

                                      <div class="form-group">
                                          <label>Product Name: </label>
                                          <span id="product-name">#VARIABLES.productdetails.Name#</span>
                                      </div>

                                      <!--- <div class="form-group">
                                          <label>Brand: </label>
                                          <select name="BrandId" id="brands_select_list" required>
                                          </select>
                                      </div> --->

                                      <div class="form-group">
                                          <input name="ProductId" id="ProductIdValue" type="hidden" value="#VARIABLES.productDetails.ProductId#" required />
                                          <input name="SubCategoryId" id="subCategoryValue" type="hidden" value="23" required />
                                      </div>

                                      <!--- <div class="form-group" class="hidden">
                                          <label>Supplier(self): </label>
                                          <select name="SupplierId" id="suppliers_select_list" required>
                                          </select>
                                      </div> --->

                                      <div class="form-group">
                                          <label>Stock Quantity: </label>
                                          <input type="number" min="0" name="Qty" value="#VARIABLES.productDetails.Qty#" required/>
                                      </div>

                                      <div class="form-group">
                                          <label>ListPrice(&##8377;): </label>
                                          <input type="number" min="0" name="ListPrice" value="#VARIABLES.productDetails.ListPrice#" required />
                                      </div>

                                      <div class="form-group product-desc-fields">
                                          <label>Description: </label>
                                          <div class="desc-fields">
                                              <cfloop index="i" list="#productDetails.Description#" delimiters="`"  >
                                                  <input type="text" value = "#i#" class="y form-control"> <br />
                                              </cfloop>
                                          </div>
                                       </div>

                                      <button type="button" onclick="appendInputBox(this);" class = "btn btn-sm btn-default" >add new field</button>
                                      <textarea name="Description" id="prdt-desc" placeholder="Product Description Goes Here..." cols="22" value="Description" class="hidden"></textarea>

                                      <div class="form-group">
                                          <label>Images File: </label>
                                          <!--- <input type="file" id="imageFile" name="Image" accept="image/jpeg" class="form-control"> --->
                                      </div>

                                      <div class="input-group">
                                            <label class="input-group-btn" style="padding-right: 0px;">
                                                <span class="btn btn-file">
                                                              <input type="hidden" name="Image_old" value="#VARIABLES.productDetails.Image#">
                                                    Browse... <input type="file" id="imageFile" name="Image" accept="image/jpeg" style="display: none;">
                                                </span>
                                            </label>
                                            <input type="text" class="form-control" readonly>
                                      </div>


                                  </cfoutput>
                              </div>

                              <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                <button type="submit" name="submit_productupdate" form="product-update-form" class="btn btn-primary">Save changes</button>
                              </div>

                            </div><!-- /.modal-content -->
                          </div><!-- /.modal-dialog -->
                        </div><!-- /.modal -->
                    </form>

              </cfoutput>

          <cfelse>  <!--- Product Not found for the provided pID --->
              <!--- something went wrong message  --->
              <cfinclude template="/commons/something-went-wrong.cfm" />
          </cfif>

          <cfelse>
              <cfinclude template="/commons/something-went-wrong.cfm" />
          </cfif>
    </div>




    <script src="../assets/js/productDetail.js"></script>
    <cfinclude template = "/commons/footer.cfm">


</body>
</html>



<!--- for admin upload product update details .. --->
<cfif StructKeyExists(FORM, "submit_productupdate") >
    <!--- <cfdump var="#FORM#" /> --->
    <cftry >

        <cfif #FORM.Image# NEQ ''>

            <cffile action="Delete"
                    file= "#APPLICATION.imagePath#\#FORM.Image_old#"
                    />

            <cffile action="upload"
                    filefield   ="Image"
                    destination ="#APPLICATION.imagePath#"
                    nameconflict="makeunique"
                    accept      ="image/jpeg,image/jpg,image/png"
                    result      ="uploadresult"
                    />

            <!--- <cfdump var="#uploadresult#" /> --->
            <cfset VARIABLES.imagename = "#uploadresult.SERVERFILE#" />

            <cfset updateProduct = VARIABLES.productCFC.updateProductDetails(FORM,#imagename#) />
            <cflocation url="#cgi.HTTP_REFERER#" addtoken="false"   />
        <cfelse>
            <cfset updateProduct = VARIABLES.productCFC.updateProductDetails(FORM,FORM.Image_old) />
            <cflocation url="#cgi.HTTP_REFERER#" addtoken="false"   />
        </cfif>

        <cfcatch type="any">
            <cfdump var="#cfcatch#" />
            <cfoutput>
                Error type : #cfcatch.type#
            </cfoutput>
        </cfcatch>
    </cftry>
</cfif>
