

<!--- CLASS/ ID STRUCTURE

.checkout_section .container-fluid
    .section #address_section
        .subsection_header #address_header
            .header_text
            .show_when_collapsed
        .subsection
            .addresses
                .address  / .no_address
            .new_address

    .section #order_summary
        .subsection_header #summary_header
            .header_text
            .show_when_collapsed
        .subsection .items
            .summary_subsection_header
                .item_name_header
                .item_qty_header
                .item_price_header
            .item
                .item_name
                .item_qty
                .item_price

    .section #payment_section
        .subsection_header #payment_header
            .header_text
            .show_when_collapsed
        .subsection
--->
<!DOCTYPE html>
<html>
<head>
    <title>Checkout</title>
    <cfinclude template="assets/libraries/libraries.cfm" />
    <link href = "assets/css/checkout.css" rel="stylesheet">
    <script src="assets/js/checkout.js"></script>
    <style>
    </style>
    <script>
    </script>
</head>
<body>

<cfinclude template="commons/header.cfm" />
<cfset checkoutCFC = createObject("cfc.checkout") />


<!--- add Address modal --->
<div id="address_modal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">New Shipping address</h4>
            </div>
            <div class="modal-body">
                <form onsubmit="validateShippingAddressAndSubmit();" method="POST">
                    <input type="text" maxlength="100" name="AddresLine" required>
                    <input type="number" maxlength="15" name="PostalCold" min="0" required>
                    <input type="text" maxlength="50" name="City" required>
                    <input type="text" maxlength="20" name="State" required>
                    <input type="text" maxlength="20" name="Country" required>
                    <input type="button">Save &amp; continue</button>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>
            </div>
        </div>
    </div>
</div>

    <div class="container-fluid checkout_section">

        <cfset cartCFC = createObject("cfc.cart")/>
        <cfset cartIsEmpty = cartCFC.isCartEmpty()/>
        <!--- LEFT that part where status in session is checkout --->
    <cfif NOT session.loggedin>
        <h4 class="jumbotron well">Please <a href="" data-toggle="dropdown" data-target=".login_toggle">Login</a> To complete Checkout Process</h4>
    <cfelseif cartIsEmpty>
        <cfset val =( #cgi.HTTP_REFERER# EQ '' )/>
        <cfif val EQ "YES">
            <cfoutput>
                <cflocation url="index.cfm" addtoken="false" />
            </cfoutput>
        <cfelse>
            <cflocation url="#cgi.HTTP_REFERER#" addtoken="false" />
        </cfif>
    <cfelse>
        <!--- loggedin >>  show address  --->
        <cfif NOT StructKeyExists(session.User, "checkout")>
            <cfset session.User.checkout = {
                step = 0
                } />
        </cfif>

        <div id="address_section" class="section">

            <div id="address_header" class="section_header">
                <div class="header_text">Delivery Address</div>
                <div class="show_when_collapsed" style="display:none;">
                    <button type="button" class="btn btn-changeaddress" onclick="revertToStep0();">Change address</button>
                </div>
            </div>

            <cfset addresses = checkoutCFC.getAddressesOfUser() />
            <div class="subsection" style="display:none;">
            <div class="addresses">
                <cfif addresses.recordCount>    <!--- populate the address inside addres section --->
                <cfoutput>
                <cfloop query="addresses" >
                    <div class="address">
                            #session.user.username# <br />
                            #AddressLine#   <br />
                            #PostalCode#    <br />
                            #City#  <br />
                            #State# <br />
                        <button type="button"  value="#AddressId#" class="btn btn-success btn-sm" onclick="storeAddressGotoStep1(this);">   Deliver Here  </button>
                        <button type="button"  value="#AddressId#" class="btn btn-info btn-sm" onclick="editAddress(this);">    Edit          </button>
                        <button type="button"  value="#AddressId#" class="btn btn-warning btn-sm" onclick="deleteAddress(this);">  Delete        </button>
                    </div>
                </cfloop>
                </cfoutput>
                <cfelse>  <!--- no addresses available for the user--->
                        <div class="no_address">
                            No Addresses.
                        </div>
                </cfif>
            </div>
            <div class="new_address"  onclick="addNewAddressShowModal();" >
                <span class=""><span class="glyphicon glyphicon-plus"></span> New Address</span>
            </div>
            </div>

        </div>

        <div id="order_summary" class="section">
            <div id="summary_header" class="section_header">
                <div class="header_text">Order Summary</div>
                <div class="show_when_collapsed" style="display:none;">
                    <button type="button">Review Order</button>
                </div>
            </div>
<!---
.subsection .items
            .summary_subsection_header
                .item_name_header
                .item_qty_header
                .item_price_header
            .item
                .item_name
                .item_qty
                .item_price
--->
            <div class="subsection" style="display:none;">
                <div class="summary_subsection_header">
                    <div class="item_name_header">ITEMS</div>
                    <div class="item_qty_header">QTY</div>
                    <div class="item_price_header">PRICE</div>
                    <div class="item_remove_header">REMOVE</div>
                </div>
                <!-- Item Container goes here containing the All the products -->
                <div class="items">
                <!--
                    <div class="item">
                        <div class="item_name">
                        </div>
                        <div class="item_qty">
                        </div>
                        <div class="item_price">
                        </div>
                        <div class="item_remove_icon">
                            <span class='glyphicon glyphicon-remove' data-dismiss-id="+ item.id +"></span>
                        </div>
                    </div>
                -->
                </div>

            </div>
        </div>


        <div id="payment_section" class="section">
            <div id="payment_header" class="section_header">
                <div class="header_text">Payment Method</div>
                <div class="show_when_collapsed" style="display:none;">
                    <button type="button">payment_review</button>
                </div>
            </div>

            <div class="subsection" style="display: none;">
                subsection
            </div>
        </div>
    </cfif>
    </div>
    <!--- <cfset session.status = "finishedCheckout" /> --->
<cfinclude template="commons/footer.cfm" />
</body>
</html>
