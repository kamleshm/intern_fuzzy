#!/bin/sh
OUTFILE=$1
TESTFILE=`echo $OUTFILE|sed s#/OUT/#/#|sed s/.out/.tst/`
TESTNAME=`echo $OUTFILE|sed s#.*/OUT/##|sed s/.out//`
REFFILE=`echo $OUTFILE|sed s#/OUT/#/REF/#|sed s/.out/.rslt/`
DIFFFILE=`echo $OUTFILE|sed s/.out/.diff/`
SDIFFFILE=`echo $OUTFILE|sed s/.out/.sdiff/`

#echo "${TESTFILE} => ${OUTFILE}"
#echo " => ${OUTFILE}"


# FUNCTION: FLApply_rules ()
#
# DESCRIPTION: Apply a series of rules to strip out expected variances
#              As new categories of variances appear, new rules must be added here
#
# EXTREME CAUTION: Please do not introduce spurious rules to pass tests
#                  Rules must be based on acceptable variances only
#                  In fact, before adding a rule try to see if the test
#                  query can be modified to obtain consistent outputs
#

function FLApply_rules ()
{
	# Please add comment when adding new rules and must put them in the same
	# sequence as the sed code

	# RULE 1: Remove date variances introduced by BTEQ
	# 	 '/BTEQ/d'

	# RULE 2: Remove time variances due to machine workload
	# 	'/\*\*\* Total elapsed time was/d'

	# RULE 3: Remove logon information that can vary
	#	'/\.logon /d'

	# RULE 4: Remove Teradata database release/version that can vary
	#	'/\*\*\* Teradata Database /d'

	# RULE 5: Remove database name that can vary
	#	'/database /d'

	# RULE 6: Remove matrix variances due to matrix id
	# 	'/is not a square matrix/d'

	# RULE 7: Remove Analysis id variances
	#	's/A[0-9]*/A/g'

	# RULE 8: Remove Notation/Precision variances - be careful with this
	#	's/\.*([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]E)//g'

	# RULE 9: Substitute only the following expected strings (store names)
	# 	 as found in the string functions. For everything else it should fail.
	#	's/WALMART//', 's/WARTHA//', 's/WAL-MART//', 
	#	's/DUANE//', 's/MARHTA//', 's/Home Depot//'

	# RULE 10a: Account for variances from shuffle functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/2590*/d'

	# RULE 10b: Account for variances from shuffle functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/[0-9][0]   */d'

	# RULE 10c: Account for variances from copula functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/10   */d'

	# RULE 11: Account for variances from sampling functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/\*\*\* ResultSet# /d'

	# RULE 12a: Account for variances from compula functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/correlation matrix/d'

	# RULE 12b: Account for variances from compula functions
	#	    WARNING: REVISIT to ensure no regressions on base
	#	'/Number of Correlations/d'

	# RULE 13: Remove references to Set command
	#	'/set r*/d'
	#	'/SET R*/d'

	# RULE 14: Remove references to view create/replace
	#	'/View has been /d'


    sed -e '/act/d' \
        -e '/LINE [0-9]/d' \
        -e '/  ^/d' \
        -e '/--.*/d' \
        -e 's/\([0-9]*\.[0-9]\{6\}\)[0-9]*\s*/\1/g' \
        -e 's/A[0-9]*/A/g' \
        -e '/testConcatString/d' \
		-e '/Time:/d' \
        $1 >& $2
    
    # Clean up terms presented in the exclusion list
    #exec 4<$FL_PULSAR_EXCLUSION_LIST
    #    while read -u4 terms ; do	    
    #         sed -e "s/${terms}//g" $2 >& $2
#	done

}

TMPOUT=`mktemp`
TMPREF=`mktemp`

TAG=`basename $1 .out`

#creating temp files from actual files applying rules to remove certain lines that may cause unwanted difference
#less ${REFFILE}
FLApply_rules ${REFFILE} ${TMPREF}
#less ${TMPREF}
#less ${OUTFILE}
FLApply_rules ${OUTFILE} ${TMPOUT} 
#less ${TMPOUT}

sdiff -a -W -t -d -w 200 ${TMPREF} ${TMPOUT} >& ${SDIFFFILE}

comp_value=$?

# If there are no differences then PASS otherwise a legitimate failure
if [ $comp_value -eq 0 ]
then
    # If there are no differences then test passsed
    echo "$TAG : 04 :         `tput smul`${TESTNAME} => PASSED`tput sgr0`" 
    rm -f ${DIFFFILE}
    rm -f ${SDIFFFILE}
else
    echo "$TAG : 04 :         `tput setaf 1;tput bold`${TESTNAME} => FAILED`tput sgr0`" 

    echo "$TAG : 05 :               ${SDIFFFILE}"
    diff -a ${TMPREF} ${TMPOUT}  2>&1 1>${DIFFFILE}
fi
#echo "TMPOUT = $TMPOUT"
#echo "TMPREF = $TMPREF"
rm -f ${TMPREF} ${TMPOUT}

