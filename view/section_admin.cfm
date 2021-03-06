<!---
    == ADMIN'S PAGE ==
    this page is for admin
    he can add category , subcategory, brands from here.
--->

<!--- <cfparam name="form.Image" default="" /> --->
<!DOCTYPE html>
<html>
<head>
  <title>Admin&#8226;eShopping</title>

  <link href="../assets/css/adminpage.css" rel="stylesheet" />
  <script src="../assets/js/adminpage.js"></script>
  <style>
  </style>
</head>
<body>
    <div class="page-header"><cfinclude template = "/commons/header.cfm" /></div>

    <cfif session.loggedin>
    <cfif session.User.Role EQ 'admin'>
    <div class="admin-panel container-fluid-page">

        <div class="admin-logo">Admin Panel</div>

        <nav>
        <ul class="nav nav-tabs">
            <li class="active"><a data-toggle="tab" href="#section-statistics">Statistics</a></li>
            <li><a data-toggle="tab" href="#section-categories">Categories &amp; Brands</a></li>
            <!--- <li><a data-toggle="tab" href="#section-product">Products</a></li>
            <li><a>list</a></li> --->
        </ul>
        </nav>

        <div class="tab-content">

            <!--- for showing statistics for products --->
            <div id="section-statistics" class="tab-pane active fade in">
                <cfset sessionTracker = CreateObject("java", "coldfusion.runtime.SessionTracker")/>
                <cfset sessionCollection = sessionTracker.getSessionCollection("Shopping")>
                <cfset sessionCountForApplication = structCount(sessionCollection)>
                <p>There are <cfoutput>#sessionCountForApplication#</cfoutput> sessions in existence for this application.</p>
                <cfset loggedinUsers = 0 />
                <cfloop collection="#sessionCollection#" item="SessionId" >
                    <cftry>
                        <cfcatch >
                            <cfdump var="#cfcatch#" />
                        </cfcatch>
                    </cftry>

                    <cfif StructKeyExists(sessionCollection[SessionId].user, "UserId")>
                        <cfset loggedinUsers += 1 />
                    </cfif>
                </cfloop>
                <p>There are currently <cfoutput>#loggedinUsers#</cfoutput> sessions having loggedin users.</p>
            </div>

            <!--- adding categories , subcategories , & brands section of tab  --->
            <div id="section-categories" class="tab-pane active fade">
                <div class="sections row">

                    <!--- adding category section --->
                    <div class="cnb-section col-sm-3  col-sm-offset-0 col-xs-8 col-xs-offset-2">  <!---cnb for Category And Brand --->
                        <h2 align="center">Add Category</h2>
                        <input type="text">
                        <button type="button" class="btn btn-success btn-sm" onclick="addCategory(this)">Add Category</button>
                        <div class="cnb-content cnb-category">
                            <input type="text" placeholder="search categories..." class="cnb-search">
                            <div class="list">
                                <cfoutput>
                                    <cfloop query="categories">
                                        <p class='list-item'>#CategoryName#</p>
                                    </cfloop>
                                </cfoutput>
                            </div>
                        </div>
                    </div>

                    <!--- adding subcategory section  --->
                    <div class="cnb-section  col-xs-8 col-xs-offset-2  col-sm-4 col-sm-offset-1">
                        <h2 align="center">Add Subcategory</h2>
                        <select style="padding: 3px; width: 100%;" onchange="enableSubCategoryTextField(this);">
                            <option value="invalid">Select Category</option>
                            <cfoutput>
                                <cfloop query="categories">
                                    <option value="#CategoryName#" id="#CategoryId#">#CategoryName#</option>
                                </cfloop>
                            </cfoutput>
                        </select>
                        <span class="clearfix"></span>
                        <input type="text" id="subcategory_textbox" data-categoryid="" data-categoryname="">
                        <button type="button" class="btn btn-success btn-sm" onclick="addSubCategory(this)">Add SubCategory</button>
                        <div class="cnb-content cnb-subcategory">
                            <input type="text" placeholder="search subcategories..." class="cnb-search">
                            <div class="list">
                            </div>
                        </div>
                    </div>

                    <!--- adding brand section  --->
                    <div class="cnb-section  col-sm-3 col-sm-offset-1 col-xs-8 col-xs-offset-2">
                        <h2 align="center">Add Brands</h2>
                        <input type="text" value="" placeholder="New Brand..">
                        <button type="button" class="btn btn-success btn-sm" onclick="addBrands(this)">Add Brands</button>
                        <div class="cnb-content cnb-brand">
                            <input type="text" placeholder="search brands..." class="cnb-search">
                            <div class="list">
                                    <cfquery name="brands">
                                        SELECT [BrandId] ,[BrandName] from [Brand]
                                    </cfquery>
                                    <cfoutput>
                                    <cfloop query="brands">
                                        <p class='list-item'>#BrandName#</p>
                                    </cfloop>
                                    </cfoutput>
                            </div>
                        </div>
                    </div>

                </div> <!---end section --->
            </div>  <!--- end cnb - section  parent --->


            <!--- product section tab content  -- not shown (not used ) --->
            <div id="section-product" class="tab-pane fade">
                <div role="navigation" class="nav nav-bar">
                    <ul class="nav nav-tabs">
                        <li><a>Category:
                            <select id="category_selectlist" onchange="fillSubCategory(this.value);" tabindex="1">
                                <option value="">select Category</option>
                                <cfloop query="categories">    <cfoutput>
                                <option value="#CategoryName#" data-categoryid="#CategoryId#">#CategoryName#</option>
                                </cfoutput></cfloop>
                            </select></a>
                        </li>
                        <li><a>SubCategory:
                            <select id="subcategory_selectlist" style="width:150px;" tabindex="2">
                            </select></a>
                        </li>
                        <li class="action_li" style="display:none;"><a><span class="product_action_button" onclick="getProductsAndShow();" onkeypress="getProductsAndShow();" tabindex="3">Retrieve Products</span></a></li>
                        <li class="action_li dropdown" style="display:none;">
                            <a data-toggle="dropdown" href="#addProductMenu" id="product_action_add_button"><span class="product_action_button" id="product_action_add_button" onclick="populateBrandsSuppliers('brands_select_list','suppliers_select_list');getSubCategoryId();" tabindex="4"><span class="glyphicon glyphicon-plus"></span> Add</span></a>

                            <div class="dropdown-menu dropdown-menu-right" style="box-shadow: 0 0 0;">
                                <form class="" action="" enctype="multipart/form-data" method="post" id="product_add_form" name="product_add_form">
                                    <div id="form-header">add new product</div>

                                    <div class="form-group">
                                        <label>Product Name: </label>
                                        <input type="text" name="Name" required>
                                    </div>

                                    <div class="form-group">
                                        <label>Brand: </label>
                                        <select name="BrandId" id="brands_select_list" required>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <input  name="SubCategoryId" id="subCategoryValue" type="hidden" value="" required/>
                                    </div>

                                    <div class="form-group">
                                        <label>Suppliers: </label>
                                        <select name="SupplierId" id="suppliers_select_list" required>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>Stock Quantity: </label>
                                        <input type="number" min="0" name="Qty" value="1" required/>
                                    </div>
                                    <div class="form-group">
                                        <label>ListPrice(&#8377;): </label>
                                        <input type="number" min="0" name="ListPrice" required />
                                    </div>
                                    <div class="form-group">
                                        <label>Description: </label>
                                        <textarea name="Description" placeholder="Product Description Goes Here..." cols="22" value="Description"></textarea>
                                    </div>
                                    <div class="form-group">
                                        <label>Images File: </label>
                                        <input type="file" id="imageFile" name="Image" accept="image/jpeg" required>
                                    </div>
                                    <div class="form-group">
                                        <button type="submit" name="submit">Add Product</button>
                                        <button type="reset" name="reset">Clear</button>
                                    </div>
                                </form>
                            </div>
                        </li>
                    </ul>
                </div>
                <div id="product-container" class="row">
                    <div id="products-list" style="padding: 10px;margin:10px;" class="col-md-5 col-sm-6 col-xs-4"></div>
                    <div id="products-info" class="col-md-5 col-sm-6 col-xs-8"></div>
                </div>
            </div>      <!--- end product view section --->


        </div>  <!--- end tab content --->
    </div>      <!--- end admin panel--->

    <!--- if not an admin --->
    <cfelse>
        <cflocation url="index.cfm" addtoken="false" />
    </cfif>
    <cfelse>
        <cflocation url="index.cfm" addtoken="false" />
    </cfif>
    <!---  include footer --->
    <cfinclude template="/commons/footer.cfm" />
</body>
</html>
<!--- end of html document --->



<!--- for uploading Image of the product to the page & updating the database with the image --->
<cftry>
<cfif IsDefined("form.Image")>
    <cfset path = "E:\EclipseWorkSpace\ColdFusion\Project\assets\images\products\medium"/>
    <!--- <cfset path = "F:\WORK\ColdFusion\Shopping\assets\images\products\medium" /> --->
    <cffile action="upload"
            filefield="Image"
            destination="#path#"
            nameconflict="makeunique"
            accept="image/jpeg,image/jpg,image/png"
            result="uploadresult" />
            <!--- <cfdump var="#uploadresult#" /> --->
            <cfset image = "#uploadresult.SERVERFILE#" />

            <cfquery name="insertProduct">
                INSERT INTO [Product]
                (Name, BrandId, SubCategoryId, SupplierId, ListPrice, Qty, Description, Image)
                VALUES
                (
                    <cfqueryparam value="#form.Name#" cfsqltype="cf_sql_char" >,
                    <cfqueryparam value="#form.BrandId#" cfsqltype="cf_sql_int" >,
                    <cfqueryparam value="#form.SubCategoryId#" CFSQLType = "cf_sql_int" >,
                    <cfqueryparam value="#form.SupplierId#" cfsqltype="cf_sql_int" >,
                    <cfqueryparam value="#form.ListPrice#" cfsqltype="cf_sql_bigint" >,
                    <cfqueryparam value="#form.Qty#" cfsqltype="cf_sql_int" >,
                    <cfqueryparam value="#form.Description#" cfsqltype="CF_SQL_NVARCHAR" >,
                    <cfqueryparam value="#image#" cfsqltype="cf_sql_nvarchar">
                )
            </cfquery>

</cfif>
<cfcatch>
    <cfdump var="#cfcatch#" />
</cfcatch>
</cftry>
