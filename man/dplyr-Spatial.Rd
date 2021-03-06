% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplyr-Spatial.r
\name{dplyr-Spatial}
\alias{arrange_.Spatial}
\alias{distinct_.Spatial}
\alias{dplyr-Spatial}
\alias{filter_.Spatial}
\alias{group_by_.Spatial}
\alias{inner_join.Spatial}
\alias{left_join.Spatial}
\alias{mutate_.Spatial}
\alias{rename_.Spatial}
\alias{select_.Spatial}
\alias{slice_.Spatial}
\alias{summarise_.Spatial}
\title{Dplyr verbs for Spatial}
\usage{
\method{mutate_}{Spatial}(.data, ..., .dots)

\method{summarise_}{Spatial}(.data, ...)

\method{group_by_}{Spatial}(.data, ...)

\method{filter_}{Spatial}(.data, ..., .dots)

\method{arrange_}{Spatial}(.data, ...)

\method{slice_}{Spatial}(.data, ...)

\method{select_}{Spatial}(.data, ...)

\method{rename_}{Spatial}(.data, ...)

\method{distinct_}{Spatial}(.data, ...)

\method{left_join}{Spatial}(x, y, by = NULL, copy = FALSE, ...)

\method{inner_join}{Spatial}(x, y, by = NULL, copy = FALSE, ...)
}
\arguments{
\item{.data}{A tbl.}

\item{...}{Name-value pairs of expressions. See \code{\link[dplyr]{mutate_}}}

\item{.dots}{Used to work around non-standard evaluation.}

\item{x}{tbls to join}

\item{y}{tbls to join}

\item{by}{a character vector of variables to join by.  If \code{NULL}, the
  default, \code{join} will do a natural join, using all variables with
  common names across the two tables. A message lists the variables so
  that you can check they're right.

  To join by different variables on x and y use a named vector.
  For example, \code{by = c("a" = "b")} will match \code{x.a} to
  \code{y.b}.}

\item{copy}{If \code{x} and \code{y} are not from the same data source,
and \code{copy} is \code{TRUE}, then \code{y} will be copied into the
same src as \code{x}.  This allows you to join tables across srcs, but
it is a potentially expensive operation so you must opt into it.}
}
\description{
Direct application of the dplyr verbs to Spatial objects. There is no need for a conversion from and to Spatial with this approach. Not all verbs are supported, see Details.
}
\details{
mutate, transmute, filter, arrange, slice, select, rename, distinct all work with attributes on the "data" slot and leave the geometry unchanged.

summarise collapses to a grouped geometries by listing all subgeometries together, it does not perform any topological union or merge, and it takes no account of the calculations done on attributes. 
This is a brutal collapse of all the data, and is identical to what is seen with spplot(x, "group"). The behaviour of geometric collapse like this
is touch and go anyway, see the examples for a what `rgeos::gUnion` does.

summarise for points and multipoints, ... todo single Multipoint for multiple points
}
\note{
Beware that attributes stored on Spatial objects *are not* linked to the geometry. Attributes are often used to store the area or perimeter length or centroid values but these may be completely unmatched to the underlying geometries.
}
\examples{
library(sp)
library(maptools)
data(wrld_simpl)
library(dplyr)
library(spbabel)   ## devtools::install_github("mdsumner/spbabel", ref = "pipe")
library(raster)  
wrld_simpl \%>\% mutate(NAME = "allthesame", REGION = row_number())
wrld_simpl \%>\% transmute(alpha = paste0(FIPS, NAME))
wrld_simpl \%>\% filter(NAME \%in\% c("New Zealand", "Australia", "Fiji"))
wrld_simpl \%>\% arrange(LON)
wrld_simpl \%>\% slice(c(9, 100))
wrld_simpl \%>\% dplyr::select(UN, FIPS)
wrld_simpl \%>\% rename(`TM_WORLD_BORDERS_SIMPL0.2NAME` = NAME)
wrld_simpl \%>\% distinct(REGION) \%>\% arrange(REGION)  ## first alphabetically in REGION
wrld_simpl \%>\% arrange(REGION, desc(NAME)) \%>\% distinct(REGION) ## last

## we don't need to use piping
slice(filter(mutate(wrld_simpl, likepiping = FALSE), abs(LON - 5) < 35 & LAT > 50), 4)


## works with Lines
#as(wrld_simpl, "SpatialLinesDataFrame") \%>\% mutate(perim = rgeos::gLength(wrld_simpl, byid = TRUE))


## summarise/ze is different, we have to return only one geometry
wrld_simpl \%>\% summarize(max(AREA))
## group_by and summarize
g <- wrld_simpl  \%>\% group_by(REGION)  \%>\% 
 summarize(alon = mean(LON), mxlat = max(LAT), mxarea = max(AREA))
g \%>\% mutate(ar = factor(REGION)) \%>\% spplot("ar")
w <- wrld_simpl
w$ar <- factor(w$REGION)
spplot(w, "ar")
\dontrun{
# compare what rgeos gives
##spplot(rgeos::gUnionCascaded(w, id = w$ar))  ## good grief, is this compelling . . .
## this is hardly a clean dissolve
##plot(rgeos::gUnionCascaded(w, id = w$ar), col = rainbow(nlevels(factor(w$ar)), alpha = 0.5))
}
}

