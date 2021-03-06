# check authenticated with correct scopes
check_bq_auth <- function(){
  cloud_scopes <- c("https://www.googleapis.com/auth/cloud-platform",
                    "https://www.googleapis.com/auth/bigquery")
  
  if(!any(getOption("googleAuthR.scopes.selected") %in% cloud_scopes)){
    stop("Not authenticated with Google BigQuery.  Needs to be one of ", 
         paste(cloud_scopes, collapse = " "))
    current_op <- getOption("googleAuthR.verbose")
    options(googleAuthR.verbose = 2)
    googleAuthR::gar_token_info()
    options(googleAuthR.verbose = current_op)
  }
}

# check authenticated with correct scopes
check_gcs_auth <- function(){
  cloud_scopes <- c("https://www.googleapis.com/auth/cloud-platform", 
                    "https://www.googleapis.com/auth/devstorage.full_control",
                    "https://www.googleapis.com/auth/devstorage.read_write")
  
  if(!any(getOption("googleAuthR.scopes.selected") %in% cloud_scopes)){
    stop("Not authenticated with Google Cloud Storage.  Needs to be one of ", 
         paste(cloud_scopes, collapse = " "))
    current_op <- getOption("googleAuthR.verbose")
    options(googleAuthR.verbose = 2)
    googleAuthR::gar_token_info()
    options(googleAuthR.verbose = current_op)
  }
}

#' Authenticate this session
#'
#' A wrapper for \link[googleAuthR]{gar_auth} and \link[googleAuthR]{gar_auth_service}
#' 
#' @param token A preexisting token to authenticate with
#' @param new_user If TRUE, reauthenticate via Google login screen
#' @param no_auto Will ignore auto-authentication settings if TRUE
#'
#' If you have set the environment variable \code{BQ_AUTH_FILE} to a valid file location,
#'   the function will look there for authentication details.
#' Otherwise it will look in the working directory for the `bq.oauth` file, which if not present will trigger an authentication flow via Google login screen in your browser.
#'
#' If \code{BQ_AUTH_FILE} is specified, then \code{bqr_auth()} will be called upon loading the package
#'   via \code{library(bigQueryR)},
#'   meaning that calling this function yourself at the start of the session won't be necessary.
#'
#' \code{BQ_AUTH_FILE} can be either a token generated by \link[googleAuthR]{gar_auth} or
#'   service account JSON ending with file extension \code{.json}
#'
#' @return Invisibly, the token that has been saved to the session
#' @importFrom googleAuthR gar_auth gar_auto_auth gar_set_client
#' @importFrom tools file_ext
#' @export
bqr_auth <- function(token = NULL, new_user = FALSE, no_auto = FALSE){
  
  if(!is.null(token)){
    return(gar_auth(token = token))
  }
  
  required_scopes <- c("https://www.googleapis.com/auth/bigquery",
                       "https://www.googleapis.com/auth/devstorage.full_control",
                       "https://www.googleapis.com/auth/cloud-platform")
  
  gar_set_client(system.file("client.json", package = "bigQueryR"),
                 scopes = required_scopes)
  
  gar_auto_auth(required_scopes,
                new_user = new_user,
                no_auto = no_auto,
                environment_var = "BQ_AUTH_FILE")
}