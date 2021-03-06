/*  -*- coding: utf-8; -*- */

/* TokenizeRu.l -- definitions for Russian */
/*                 iso-8859-5             */
/*                 cp1251                 */
/* run through a filter to discriminate charsets */

%{
#include <string.h>
#include "Tokenizer.h"
#include "TokenizerLexer.h"
%}

%option 8bit batch noyywrap

  /**** character classes ****/
LETTER_LAT    [A-Za-z]
LETTER_LAT_UC [A-Z]
LETTER_LAT_LC [a-z]
 /* iso-8859-5 and cp1251 have the same repertoire of cyrillic letters */
LETTER_CYR    [���������������������������������������������ﰱ�����������������������������ϡ�������������]
LETTER_CYR_UC [�������������������������������ϡ�������������]
LETTER_CYR_LC [����������������������������������������������]
LETTER    ({LETTER_LAT}|{LETTER_CYR})
LETTER_UC ({LETTER_LAT_UC}|{LETTER_CYR_UC})
LETTER_LC ({LETTER_LAT_LC}|{LETTER_CYR_LC})

CHAR   .

DIGIT     [0-9]

HSPACE    [\x20\x09\xa0]
          /* normalize also non-breaking space */
VSPACE    [\x0a-\x0d]
NEWLINE   [\x0a\x0c\x0d]
SPACE     ({HSPACE}|{VSPACE})

 #define _EQUAL_SPACE_(c) (c=='\x20'||(c>='\x0a'&&c<='\x0d')||c=='\x09'||c=='\xa0')
 /* o.k. for iso-8859-5, cp1251 */

CONTR     [\x00-\x1f\x7f-\x9f]
NO_SPACECONTR [^\x20\x09\xa0\x0a-\x0d\x00-\x1f\x7f-\x9f]

SOFTHYPHEN '�'
HYPHEN    [-{SOFTHYPHEN]
 #define _EQUAL_HYPHEN_(c) (c == '-' || c == '\xad' /*soft*/)
 #define _EQUAL_REAL_HYPHEN_(c) (c == '-')


  /**** DEFINITIONS FOR END-OF-SENTENCE DETECTION ****/

EOS_PUNCT [.!?]
ALL_EXCEPT_EOS_PUNCT  [^.!?]
EOS_ADD   [\'\"\)\]\}>]
          /* \xbb = '' ; cp1251 only: '' and []*/
BOS_ADD   [\(\[\{<\"\'`]
          /* \xab = '' ; cp1251 only: [] */
BOS_MARK  ({BOS_ADD}*({LETTER_UC}|{DIGIT}))

OTHER_PUNCT [,;]
          /* \xb7 = '' (middle dot) ; other: cp1251 only */
PUNCT     ({EOS_PUNCT}|{EOS_ADD}|{BOS_ADD}|{OTHER_PUNCT})

  /**** and exceptions: points or other BOS_MARKs that (usually) are not EOS marks ****/

PS        (\.{SPACE}*)

DATE_DAY  (([012]?[0-9]|3[01]))
WORD_MONTH (([��]��\.?|��(�|�))|[��]��(\.?|���(�|�))|[��]��(\.?|��?)|[��]��(\.?|��(�|�))|[��]�(�|�)|[��]�[��](\.?|�|�)|[��]��(\.?|����?)|[��]��(�?\.?|����(�|�))|[��]��(\.?|���(�|�))|[��]��(\.?|��(�|�))|[��]��(\.?|���(�|�)))
DATE_MONTH_ROMAN (i{1,3}|iv|vi{0,3}|ix|xi{0,2}|I{1,3}|IV|VI{0,3}|IX|XI{0,2})
DATE_MONTH_NUM (0?[1-9]|1[012])
DATE_MONTH ({WORD_MONTH}|{DATE_MONTH_NUM}\.|{DATE_MONTH_ROMAN}\.)
DATE_YEAR ([1-9][0-9]{0,3}|0[0-9])
DATE_YEAR_POSTCLASS ((��|��(\.|��))(�{PS}�|�{PS}��){PS})
DATE  (({DATE_DAY}{PS}{DATE_MONTH}{SPACE}*{DATE_YEAR}({SPACE}*{DATE_YEAR_POSTCLASS})?)|({DATE_DAY}{PS}{DATE_MONTH})|({DATE_YEAR}{SPACE}*{DATE_YEAR_POSTCLASS}))

ABBR_WITH_POINT1      (����|����|�����|��|���|����|���|��|��|���|���|�{PS}�{PS}�|����|���|������|��|��|���|���|����|�{PS}�|����|���|����|��|���|���|����{PS}����|����|�������|����|������|�{PS}�|���|���|���|���|��|��|��|��{PS}�������|��{PS}����|��{PS}������|����|����{PS}���|���|���|��|��|�{PS}�|��|����|�����|��|����|�{PS}�{PS}�|���|�����|���|�{PS}�|�|���|����|����|����|���|��|�|���|����|�|�{PS}�|�{PS}�{PS}�|��|��{PS}�|�����|���|���|�����|�����|�����{PS}��|�|�{PS}�|�{PS}�|�{PS}�{PS}�|��|��|���-�|��|��{PS}���|���|��|����|���|�|���|����|��|�|���|��|�{PS}-�|���|���|�|��|���|���|���|����|����{PS}����|�|�{PS}�|���|���|�����|���|���|����|�|�{PS}�|�����-�|�����-�|�����-�|������-�|�����-�|�����-�|�����-�|������-�|�����-�|����{PS}�����|���|��|��|���-�|�����|��|��|��|�����|����-�|����-����-�|����-���-�|���-�|���-���-�|����|�������|����-�|����-����-�|���|���-�|����-�)
ABBR_WITH_POINT2      (�|�{PS}��|����|���|���|����|���|�|�{PS}�|���|���|����|���|���|��|���|���{PS}����|���{PS}���|����|����{PS}����|����{PS}���|��|��|����|���|�|�{PS}��|�{PS}�|��|���|���|����|���|����|����{PS}����|����|���|��|�����|�����|��|�|���|������|�����|���|����|��|�|���|��������|���|��|���|����|����|����|���|������|����|��|�������|�����|�������|����|����|������|�����|��������|����|�|����|���|���|���|���{PS}��|��|���|���|�����|�|�{PS}-�|�{PS}-�|�{PS}�|�{PS}�|��|��|���|���|���|���|���{PS}�|��|��|��{PS}�������|��{PS}����|��{PS}������|�����|����|���|����|����|����{PS}����|����{PS}���|����{PS}���|����|�����|���|�����|����|��|���������|��|����|���|���|�|�{PS}-�|�{PS}�|�{PS}�|�{PS}�|�{PS}�|�{PS}�|�{PS}�|���|���|����|��|���|���{PS}����|���{PS}��|���{PS}���|���{PS}��|�|����|��|��|������|������{PS}-����|����|�����|�����|�|�{PS}��|��|��|�����|��|�|�{PS}�|���|�|����-�|���-�|���|���-�|����-�|���-�|���-�|����-�|���-�|����-�|����-�|���-�|�����|����|����|��|�|���|��)
ABBR      (({LETTER_UC}|{ABBR_WITH_POINT1}|{ABBR_WITH_POINT2})\.)
 /* the abbreviations are literally (spaces may appear after a
 "intra-abbr." period): ����. | ����. | �����. | ��. | ���. | ����. |
 ���. | ��. | ��. | ���. | ���. | �.�.�. | ����. | ���. | ������. |
 ��. | ��. | ���. | ���. | ����. | �.�. | ����. | ���. | ����. | ��. |
 ���. | ���. | ����.����. | ����. | �������. | ����. | ������. |
 �.�. | ���. | ���. | ���. | ���. | ��. | ��. | ��. | ��.�������. |
 ��.����. | ��.������. | ����. | ����.���. | ���. | ���. | ��. | ��. |
 �.�. | ��. | ����. | �����. | ��. | ����. | �.�.�. | ���. | �����. |
 ���. | �.�. | �. | ���. | ����. | ����. | ����. | ���. | ��. | �. |
 ���. | ����. | �. | �.�. | �.�.�. | ��. | ��.�. | �����. | ���. |
 ���. | �����. | �����. | �����.��. | �. | �.�. | �.�. | �.�.�. |
 ��. | ��. | ���-�. | ��. | ��.���. | ���. | ��. | ����. | ���. | �. |
 ���. | ����. | ��. | �. | ���. | ��. | �.-�. | ���. | ���. | �. |
 ��. | ���. | ���. | ���. | ����. | ����. | ����.����. | �. | �.�. |
 ���. | ���. | �����. | ���. | ���. | ����. | �. | �.�. | �����-�. |
 �����-�. | �����-�. | ������-�. | �����-�. | �����-�. | �����-�. |
 ������-�. | �����-�. | ����.�����. | ���. | ��. | ��. | ���-�. |
 �����. | ��. | ��. | ��. | �����. | ����-�. | ����-����-�. |
 ����-���-�. | ���-�. | ���-���-�. | ����. | �������. | ����-�. |
 ����-����-�. | ���. | ���-�. | ����-�. | �. | �.��. | ����. | ���. |
 ���. | ����. | ���. | �. | �.�. | ���. | ���. | ����. | ���. | ���. |
 ��. | ���. | ���.����. | ���.���. | ����. | ����.����. | ����.���. |
 ��. | ��. | ����. | ���. | �. | �.��. | �.�. | ��. | ���. | ���. |
 ����. | ���. | ����. | ����.����. | ����. | ���. | �����. | �����. |
 ��. | �. | ���. | ������. | �����. | ���. | ����. | ��. | �. | ���. |
 ��������. | ���. | ��. | ���. | ����. | ����. | ����. | ���. |
 ������. | ����. | ��. | �������. | �����. | �������. | ����. |
 ����. | ������. | �����. | ��������. | ����. | �. | ����. | ���. |
 ���. | ���. | ���.��. | ��. | ���. | ���. | �����. | �. | �.-�. |
 �.-�. | �.�. | �.�. | ��. | ��. | ���. | ���. | ���. | ���. |
 ���.�. | ��. | ��. | ��.�������. | ��.����. | ��.������. | �����. |
 ����. | ���. | ����. | ����. | ����.����. | ����.���. | ����.���. |
 ����. | �����. | ���. | �����. | ����. | ��. | ���������. | ��. |
 ����. | ���. | ���. | �. | �.-�. | �.�. | �.�. | �.�. | �.�. | �.�. |
 �.�. | ���. | ��. | ���. | ����. | ��. | ���. | ���.����. | ���.��. |
 ���.���. | ���.��. | �. | ����. | ��. | ��. | ������. |
 ������.-����. | ����. | �����. | �����. | �. | �.��. | ��. | ��. |
 �����. | ��. | �. | �.�. | ���. | �. | ����-�. | ���-�. | ���. |
 ���-�. | ����-�. | ���-�. | ���-�. | ����-�. | ���-�. | ����-�. |
 ����-�. | ���-�. | �����. | ����. | ����. | ��. | �. | ���. | ��.
 */

  /**** DEFINITIONS OF TOKENS ****/

WORD      ({LETTER_LAT}+|{LETTER_CYR}+("-"{LETTER_CYR}+)*|{DIGIT}+"-"{LETTER_CYR}+)
          /* includes also words containing '-' (``�����'') */
          /* and special for Russian inflected numbers: 1-��, 3-��, � 4-� ����� */
          /*                     and words like 16-�������, 20-�����   */

NUMBER    ({DIGIT}+)
FNUMBER    ({DIGIT}+([,\.]{DIGIT}+)?)

  /**** internet and e-mail adresses ****/
WWW_VALID  [A-Za-z0-9_-]
WWW_HOST   ({WWW_VALID}+(\.{WWW_VALID}+)+)
WWW_PROT   ((https?|ftps?|file|news):\/\/)
WWW_ADR    ({WWW_PROT}|www\.){WWW_HOST}(\/{NO_SPACECONTR}+({WWW_VALID}|[\/]))?
EMAIL_USER ({WWW_VALID}+(\.{WWW_VALID}+)*)
EMAIL      ((mailto:)?{EMAIL_USER}@{WWW_HOST})
WWW        ({WWW_ADR}|{EMAIL})


  /**** exceptions to hyphenated words, i.e. words including a hyphen            ****/
  /**** make sure that there is a {HP} in every word, or tokenizer will hang !!! ****/
HP         {HYPHEN}{HSPACE}*{NEWLINE}{HSPACE}*
 /* actual only dummy definitions: */
HYPH_LEX   abcyw��xwec{HP}abcyw��xwec
HYPH_WORDS abcyw��xwec{HP}abcyw��xwec
  /** yes it works, having a exclude-lexicon: the lines should not be too long **/
  /** but the scanners becomes very big (4 times) and about 3% slower with the lexicon abow **/
 /* HYPH_WORD ({HYPH_WORDS}|{HYPH_LEX}) */
  /** so we don't use it **/
HYPH_WORD {HYPH_WORDS}

  /* STATES used */
%s  contHyph  EOScontHyph  EOS  WWW  contHyphWWW  EOScontHyphWWW  EOSWWW
%x  testEOS noEOS

%%


 _TEST_IF_OPTIONS_SET_


 /**** hyphenated words: ****/
<contHyph,EOScontHyph,contHyphWWW,EOScontHyphWWW>{
{HYPH_WORD}                 { _UNPUT_COMBINED_BS_WORD_ }
{WORD}{SOFTHYPHEN}/{WORD}   { _UNPUT_WORD_WITHOUT_LAST_CHAR_ }
{WORD}{HYPHEN}{HSPACE}*{NEWLINE}{HSPACE}*/{LETTER_LC}   { _UNPUT_WORD_WITHOUT_HYPHEN_ }
}

 /* www adresses */
<WWW,contHyphWWW,EOScontHyphWWW,EOSWWW>{
{WWW}/{PUNCT}              return TOK_WWW;
 /* exclude ')' etc. at the end of an www adress */
{WWW}                      return TOK_WWW;
}

 /**** rules relevant only for EOS detection: ****/
<EOS,EOScontHyph,EOSWWW,EOScontHyphWWW>{
 /* exclude short snippets in parenthesis somewhere in the middle of sentence */
 /* (an expensive rule)                                        */
({WORD}|{NUMBER}){SPACE}+"("{ALL_EXCEPT_EOS_PUNCT}{1,40}{EOS_PUNCT}.{0,40}")" |
 /* exclude dates and selected abbreviations */
{DATE}                     |
{ABBR}                     { no_eos_length = (yyleng);
                             yyless(0);
			     BEGIN(noEOS);
                           }
 /* EOS only if EOS_PUNCT followed by space and uppercase letter */
 /* {EOS_PUNCT}/{EOS_PUNCT}    return TOK_OTHER; */
{EOS_PUNCT}+/{EOS_ADD}*{SPACE}+{BOS_MARK} {
                           yyless(0); BEGIN(testEOS); }

}

<testEOS>{
{EOS_PUNCT}                |
{EOS_ADD}                  return TOK_OTHER;
{SPACE}+/{BOS_MARK}        yyless(0); BEGIN(stateINITIAL); return TOK_EOS;
{CHAR}                     yyless(0); BEGIN(stateINITIAL); return TOK_EOS;
}

<noEOS>{
{WORD}                     test_no_eos_length(yyleng); return TOK_WORD;
{NUMBER}                   test_no_eos_length(yyleng); return TOK_NUMBER;
 /* noEOS are actually dates and abbreviations, but no floating point numbers */
{HSPACE}*{VSPACE}+{SPACE}* test_no_eos_length(yyleng); return TOK_VSPACE;
{SPACE}+                   test_no_eos_length(yyleng); return TOK_HSPACE;
{CHAR}                    test_no_eos_length(yyleng); return TOK_OTHER;
}


 /**** general rules: ****/
{WORD}                     return TOK_WORD;

{NUMBER}|{FNUMBER}         return TOK_NUMBER;

{HSPACE}*{VSPACE}+{SPACE}* return TOK_VSPACE; /* skip horizontal spaces         */
^{HSPACE}+                 ;                  /* at the begining or end of line */
{HSPACE}+                  return TOK_HSPACE;

{CONTR}+                   ;

{CHAR}                     return TOK_OTHER;


