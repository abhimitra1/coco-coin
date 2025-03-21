//Fourth Strategy - Lock tokens strategy.

module coco_coin::coco;

use sui::coin::{Self, TreasuryCap};
use sui::balance::{Balance};
use sui::clock::{Clock};
use sui::url::new_unsafe_from_bytes;


const EInvalidAmount: u64 = 0;
const ESupplyExceeded: u64 = 1;
const ETokenLocked: u64 = 2;

public struct COCO has drop {}

public struct MintCapability has key {
  id: UID,
  treasury: TreasuryCap<COCO>,
  total_minted: u64,
}

public struct Locker has key, store {
  id: UID,
  unlock_date: u64,
  balance: Balance<COCO>,
}

const TOTAL_SUPPLY: u64 = 1_000_000_000_000_000_000;
const INITIAL_SUPPLY: u64 = 900_000_000_000_000_000;


fun init(otw: COCO, ctx: &mut TxContext) {
  let (treasury, metadata) = coin::create_currency(
    otw,
    9,
    b"COCO",
    b"COCO",
    b"Meet COCO, the cutest Pomeranian puppy meme coin wagging its way through the blockchain! Join a world of fun, community, and adorable rewards.",
    option::some(new_unsafe_from_bytes(b"data:image/jpeg;base64, /9j/4AAQSkZJRgABAQAASABIAAD/4QBYRXhpZgAATU0AKgAAAAgAAgESAAMAAAABAAEAAIdpAAQAAAABAAAAJgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAABQKADAAQAAAABAAABQAAAAAD/wAARCAFAAUADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwACAgICAgIDAgIDBQMDAwUGBQUFBQYIBgYGBgYICggICAgICAoKCgoKCgoKDAwMDAwMDg4ODg4PDw8PDw8PDw8P/9sAQwECAgIEBAQHBAQHEAsJCxAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQ/90ABAAU/9oADAMBAAIRAxEAPwD9/KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9D9/KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9H9/KKKKACiiigAooooAKKKKACiiigAoopkkiRLvkYKo7ngc8Ck3bVgZmpa5pGj+WNUu4rUzHCCRgpY+2araL4m0XX1zptwHcAMY2G2QBuQSp5wRyD0NeC+M9bn1rVbfUNGmQQTxqrrIiv+6TOUYNnhnJzjrtHpVBZYhZR2aQ7Gtc/ZJkYrNbjOdquOSn+ya/PsXxxGliJU0rxX4/P/AIH+Z9lhuE5VKEZt6v8AD5f8H/I+qKK+efD/AIw1u3nntL66AZSht5ZATE6kYKTAcg7gcOvIB5Br2XQ/ENrrG+2YCC/gAM1uWyyhujKejIezDg/Xivp8pz+hjIp03Z9meFmOT1sNJqa07nQ0UUV7Z5QUUUUAFFFFABRRRQAUVzviHxHZ+H7dGlUzXM5KwQJjfKwGTjsFA5ZjwBya+ffE2teJNeubeI3bRxsWabyiyxIo+7HGOCxJPLt2BwBmvn864ioYJe9rLsezlWSVcVLTRdz6K1rxDpHh+3NzqtwsK9h1dsf3VGSfwFP0vXtH1rzBpV5HctCcSBGBKn0I7V813YNxZvbsGeWdQs88jlpXUfwBv4E9l69zS+EdWl8NaqL/AFJxFp1ispIjUBVhdMBQB1+cLjPfnOSTXz2G44jUxEabSUX+Hz/4B7VbhOUKEpp3kvx+Wv5/5H1VRUUU0U6CSJg6nuDnpUtfoCd9UfGBRRRTAKKKKACiiigAooooAKKKKAP/0v38ooooAKKKKACiiigAooooAKKKKACvM/itqj6f4YEEEhiuL2eGKNh1B3BiR9AtemV8ufFrVdS1bxdY6JCqyWFgI7gsp+bdJuUk88gFfrXy3GOZfVsBNx+KWi+f/APo+FcAsRjYKWy1fy/4JjWlv5Sh2A8wrhsdM7mbj2+ar4FcV4n1q70iCD7GQHkfkkZ+UckfjWto3iGz1aJQDsnAyyH174r8UeFqOmq3Rn7LLLqkaSqpe6b7DIpfPuh5DW9wbS7syWtboDJhY9VcD78L9HT05HIqJpUUcmoTKD93mpw2MlRnzQZ51bCKrDlmj2bwb8T9M8TTf2TfRNYarboBcRsQYxKGCsqP/ECWUqe6sDXqNfFepaW8hN9p5MV1GF5XjeEcOAfoRxX0/D450CLT7GfUbtYprqCOUpgkjcueQOlfrnDPFkcRTksVJRcbavS9/wBT83z/AIbdCcXh03zX0WtrfodrRXDT+O9EuIXj0e9ge8x+7jmLRq5/u7iOCaueFfF1j4oglESG3vLRtlxbv9+Nv6qexr6mjm+GqVFThNNva39bnztTLa8IOc4NJdzraK43VvHOhaTcvZu5mlhBaQRjITHQE+pPAA5zWPZ+PbeItPrs8Fmrfcto90sy/wDXRl4B/wBnHHrWNTPcJGfI6i89dF8y4ZViJK6g/uPSq4Pxn4+03wbEzXUT3EvkvIqJ1ZgVVE+rswA9OTUrePPD9xYXlzYXIeW2heXYwKk7BngHGa+bYrW71ZhqesytLPJI0oBP3ctuUfhXzvEnFsaFOMcK1KUuu6R72RcNSrTcsSmlG2mzZu219rGptJq+uuGv7wYcL92KPOVhj9EHfux5PbFioQwUUvmp61+R18TOpLnqO7P0Onh4wVoKyJaxNds2vNOntIjtadQuT04Ibn2yKh1zxDa6Pbkkhp2HyJ6+59qx/DGuXetWs5vcGSJ8DAx8p6Vc8LP2Tq9D0qGAqqn9Ya91M90+CetTXuh32jXj+Zc6Zcvlj1dZiXDH8c17TXyh8NdR1HSPiFJp8aLHZasGaRm6nyIywI9BuPNfV9fs3BOPdfL4c28fdfy/4B+ScYYJUcdPl2laS+e/43CiiivrD5cKKKKACiiigAooooAKKKKAP//T/fyiiigAooooAKKKKACiiigAooooAhuH8qCSX+4pb8hmvirTzeSXbXk7+ZG6MFJ++oaQybT6gFjg/hX2F4g1e00PSLnUr1WeGBCzKgBYrwDgEjPWvjzSLu3urZpLckxCR1UkEEqrEA4PI4r8n8Sq/vUaal3uvuP0rgGg3CtNx00V/vMLxhMkhhtiPmHzA/pXGI0ts6z25IkQ5GOtbevu0l+7NzjgVydxdrGAHfbk8n0HrXlYKny0Ix8j94y+jago+R6fpWu23iG1QQzDzTlXCnDBhx06g59Rx3p3iODxjH4WuIvDarJrOVjjYkAbSwBkG7jIXnnvmo/DHhnTmSeeW3VZZ9rGVTtkDqODx3A6MOoxnivTEjKqFY5wMZPU18nWowU3y7Hw+MxkYVf3a0T6mRodle2GkWdnqVwbu6hiRZZm6vIB8x/OtFLaFW3qg3evU1ZwKTjtTSseRKbbuyOZFnXbKNw96qWUd3pGqJqulSeVIUaKTn7yMP5g8itDiggYpxk4yUouzXUnRxcHs+hni2OOGOSwcnuWHQn6VYjj8pQkfyjvjr+dTYPWkFSm11Kk7lOWyhlJJBBPBIOMg9QatbRjFWpfszbfI3A853Y/DH9apxzW8zSLDKshiba4VgSrYzhsHg47GnUhZ6EwquSuzN1MXhtmjscLM/yhjyEz1YjvjrjvXI6nrEfhmxka6l3FMKhdssxPGW+p7D8K9CZdwI6V5t4s8PLcx23lL88LFjOx3Sb24/dr08xugc/cGceyowi5rm2PTwVWPMlPY4W4lku5zPO5eR+Wz1U/3T6Eenb6113hC5WKWWyxgv8APn1xgAV53ZBFkeO2cGNWIGOQccHB7j37102kTSRajE0Y+YnHtz1/KvsMfTUqDj5H32Pw6lh3HsjuNRTUm1BZLJxDH5TRyS/xbWYFlQf7WME+mfWvtDR7pr3SrO7f700Mbn6soNfG2sXDW+nzTRKXYKQoAySTwMCvrLwXqtlrPhfTr7Tg4tzEsa+YNrfu/kOR9RXo+Gtf360G+i0+8/CuP6H7ujUUerV/uOoooor9YPzIKKKKACiiigAooooAKKKKAP/U/fyiiigAooooAKKKKACiiigAooooA8a+NMM8vh2IWl0LeVmeLlgCVlQocA9cEjIr5/thPbaKhuYxFP5fzqDnD45wR1r2T4q/YdS1iCyuISzWyZwSdrbuh29MjnBHNeR6/ui02QQRtI2OFXJJNfgnGFZVMzk1srL7tz9u4KpuODpwfV3PJ76/kmcJEpZm4AAySa2NJ+Ht9q8Rm1ZntQ33VG0tj354p3gmK9gvJJ9Vsbm2YH5ZBGrJj6EEj8K90iKlAyncCOtZYrGzh7sD7fN88qUZeyoaeaMPQNOu9FsY9Onc3EUA2xysMHHZW9x/KtlLqN5GiH3l61M8soiMO8+WTu2543dM49ayvLWOZpieteJiKut18z5ON6jcp7s0y47mk8xc4rIlulHApI5mJ5B6Z/D1rnVa7NXh7K7NxTT6rIyZ/duHBqcHPFdSOOQ6oycVJVOSVFOGIXPc9PxpSY4RuPMoHSsjSdJs9MudRubaGCJ9SuPPkMMXls7bFXMhyd7cfe44wMcZMc07Iec9AenY0+3uwx5Nc6xGtjt+re7dG7WFr2m3WsWMmm29wbRZxteVQC4XuFz0J6Z7VduNSsdPtzdahcR20K8F5GCKM+5OKvI6SIskbBkcAgg5BB6EGt4Ts7owi5QakjxS++H11o8SvortcLGOVkKg49ulcjPqP2UFZ8xSg7dpODn0zmvpeQAqc14n4+0i51JrdNMsLi4lEis0ibY1Cg9DwGYH/Jr28Hmcm+SZ9ZlGdznLkxDvfqdlaTTz6GJVUS3AhyAOMvt6fnXv3wWeaDwsmlXE6zSWoXOGDEE53cDoN2a8J0GCWKwRLtPLkxyvp7V3/wAKZY7HxlcWEaSmOaHKBWbykI+8SoGMn+8xPoK34MxXssziv5rr9T4XjOh7TB1FH7Lv+n6n03RRRX7yfigUUUUAFFFFABRRRQAUUUUAf//V/fyiiigAooooAKKKKACiiigAooooA8Y+J+lX0zR31tDJKiL80hdFiixxyMbzn615LYESj52DsDg4r0zx94mv9Uvrjwzpcpt7KD5LqVTh5GPJjU9gB94jntXHW9tBbRrDAoRVGBgV+E8XToVMbKVHXv2v5H67w46tPBxhVXp6eY9VKjAOPpSkcZqXFRtwK+cPU6mD4h13TfDekz61q0hjtbcDcVUsxJOAAB3JNY+meILTxFo9trdgsiW92pZBKu18A45HPXHFdBfw213BJb3kSzQyDDI4DKR7g8GueupYolEUShFQYCrwAB0AFcOIq6Hr4OjFpaakMlxh89cHoa0JdQjNvH5fBQ/KDyQD1X3FcxJIC1Ihya86NVrQ9SphIyabO20+XcB6VtbwO9cdaXPlr9KtNqyExBT9/PP0r0KeISVjzK+Dcp6HUM+Frnr+fafpTF1WNkmBPMeP1rIup/MXJqcRXutCsJgmpe8XXv4vsjK53O5Jb3Pb8BWbbXJDYrOY5PFIr7WzXD7Rt3PVhhYxTSHeLfBWn+PLaytdSuJYYrSXzSseP3gIwVOf0PUV6RaQxW0EdtAoSKFVRFHRVUYA/AVzWn3AOOa6SJwRx3r1MPO6PFxnPZQb0W3zNBYA9vJOZFGxgoU/ebPcD0HeoMdqZLcQWsD3N1KsMUYyzuwVVHqScAVNgHkd67W00rI8hJpu7Mi/jkELtGdpA64z+ld78JNOvxcSahcQzRoyn96rxNBJ227SvmIw7jNcu8YZSp5BruvAfiH+zbiHw9cD/RpiRCxP3HPRfXB7enTpX0nB86FPHRlVdm9F6nlcSzqzwUoU1pu/Q9qooor9zPyUKKKKACiiigAooooAKKKKAP/W/fyiiigAooooAKKKKACiiigAqvdz/ZrWa4xnykZsDqcDNTk4GfSvOdX8XXsjS6fpdmwYnYJ5OEX/AGsEDPtzXn5jj6dCF57vY6sLhZVZWieQRR3CM/2wEXDMzSg8nexy2fxrxzx58ZrDwhqbaLYWX9oXUIBlJfYiE8hehJOOvpXr8c6SXEsSP52wnMnZm7ms5fCPhN57nVJtPtRdu28s8Id5HPU7iDiv56nFzk+V99z9uwdajSalXg5K2y01/OxX8IeJP+Es8O2mvi2az+1BsxvyQVJXIOBkHGQfStyaRUHNVp7yK1TauFAGABxXnXjPx5onhDQ7rxF4guvsmnWm0zT7HkWJXYL5jhASEUnLtjCrknABNc0qjclTjq2bQw3M3O1onU39+q5VTzVSHS1mia61C4EEQ5JJAwPdjwK/Or4xfth+N/hh4bi1h/A1rcnUHMVhqkOsW95pdy+CwkiWHE7rt5KlVxwC3TPxtqeg/Gf4+alYv8V/E+r6tr+tQm80vwdoFqby/Nr1E8lsrxW1jB/dedjIw52EEE/YZDwBXxX77ESUY9Orf3fqcWacQ0cNHlpN36n7wHQbC9tjc6RdrOo6MrLIhP8AvLxXNESW8phmG11OCK/nDu/EnxZ/Zn+JEul6UPEHw+1mz2O1rqDBJHVuVMsSqIZY2HTKsp7V+z37N/7TNj+0R4Pe61OKKx8W6IUi1K3iyI5Uf/V3MQOSEcggrk7WBGcEVhxbwLLA0vrNKXNDr0a9To4d4jWJn7Kb32Pqf7SsSZJ4rnJL1hviB4Utj6NippLjchB71hSOQxFfmzmz72hQSubVtduSqk8Egn3x0rdMu5Qe1cfbPlxitprjCgZ7VXPoKrSTZoqGlkEcQ3MxwAPWt9tIsLG2F1rV6lop43O6xoD6bmwDXxz+01+0xbfs8eC4rrSI4rvxbre+LTYZfmjhRMeZcyqOSqZAVeNzEDoDX4x+ILn40fFDT7v4x/EfT/E/iTwyjN5usLDK1nE24KQkrobeNAeMKAAeK/S+EeApY2j9Zry5YPbq2fBcQ8SrD1PYwex/TG9lFBCt3ZXAnhYZBBBBHqGHBq3ZakrYUmv5wfhp418U+EYX8Qfs/ePb2O9s1Mt14e1BfKkkiXlmji3yW12gH3guyUDkJjLD9APg/wDtreM/iJoVzcw/D83d9pu1Lq7i1G3tNOicjIeZrlg8KEAno/QgE1pnvAGIwv7zDyUofc19/wChGWZ7QxMeSppL7z9YEeKeMo4Dq3UEZB+oNRaVYDS7FLL7TNdbGc+ZcP5kh3sWwWwOBnC+gAFeP/Df4l6J498Ow+ItDu0u7RnaEzRb/Ikki+WQwO6r5kYbIWQDDY4rqfGWijxr4an0aC7NpcMySQyqT8skZyucYOOxr4yNVxbhNWaO54Bcyu7RfX9T0zyyUZ8jCYyCcHn0HeoSGDK8R2uhDKfQg5BrjfAtj4j0zw3bWHiq5S8v4Cy+arFsx5+TcxAJbHU4rp7q6jtwrSkqhOCRziuqNSzUl0POqUHzShe+59RWM7XNpDPINruoLD371brzDRfGdpaWNvZ3Mv2pgq7XjRuUI+Xdx1xXpqNvUN0yM1/RGAx0K8LwevU/F8XhJ0pWkh1FFFdxyhRRRQAUUUUAFFFFAH//1/38ooooAKKKKACiiigAooooADXz14um1C/1K5MavYaUGKeYwxNct3WFeCqerd/U8Cver9547KZ7Ubpgp2D/AGjwP1r5Y1jVS/iCTSbWc3Fvp7FZ7iQktNcEfvDn2PAA4UDAFfD8cY1UqEYvr/X3d/kfVcKYR1aza6fh/wAHovn6lqCBIIxHEoVR2p8qsybV608GnV+Pn6RzO9zkr3Qbi7JImK59s1yeo+F7+KN1bZcRMCGUjqCMEEHIINej6lqSaakZZC5kOBzgD6k1mLqKanDIUiZPL4yeQfoe9FbJpex9vbTvc9rC42vFJ/ZPwr/aM+G3g/wr+0VG2gaFBpml6ToJ125t4F2QyXAneMNsHyrlymQoA46VS/YN/a48Mfs//G3xJ4y+Lcc8+m+NbTyLrUIYzPPaSpL5qN5Y+Zom+6yrkjCYBC4r7q/aZ+GtldeP9B8W6tMljo3ibTbvwlqF7MdkNnNeSLcabPM+MJEbqMRSOeFEgJr5n8CfskfBf4m/DW6+CPjjWrf4S/H3wPe3iO2qMIotYsppDJbSssjKs0ew7VkgYsoGSGUiv3nhLGqtgKTbu0kvmtz8x4plCNadOS0bvp2aVjwv/go9+1J8Pv2oPixoOq/DG3nfR/DentZC9uITBLeSSymQlYz84jTgJuAYkscDjPCfsHeKb3Rv2g9I06Fj5Os2t3ZzLngqIjMpI9njFeU+EfEWqfsu/tHWur2EeleNr/wLqskQWJmudOvnQNE3lPtBYZY7HC5DAEZxX33+xF8I/EfxO+OviX4/+JdPh0iE3N9MIYE2QJfai7NJFCvTbbxsUPozbeqmtOKq1OGX1oz6qy9XscnC6ksZTcNk7t+R+nRMj4SNS7HoAMmoX028LfvMR+zEKf1r26WLw94V0W8v7547HT7OCSa5uJTtCRRqWd3c9AACT6V+eV7+2rYazNK/wi+H9nqWkoxWPUtf1aDSkuApxvit2DzFD2LbeO1fgOX8MVsTd0+m76H7F/rJ7zjCm36av/gH1RBpt2OYsSkdkYMfyFSs7KNjqVYdQRg18oaV+3F4Y0zU7ex+M/gW10XT7iRYzquhalFqlvb543zRoI5kUd2Xd9K/Reex0PxDplvdW7JdW08SSQTxtuDxuoKOrjqCCCD3pZlwzXw1va6X27MmPEv7zknBrvfRr/M/m4/b28TX2uftA6rpczEQaLaWdnAvYK0QnYge7yGv0m0//gpX+zlF+xh/wrmTTp4PF6eGm0D+wY7RvsrTm2NsJRNjyfIYnzDk7+o2k8n5o/4KEfADVrHxvbfEnSYRcW+sRQQNkfKb22yscb9h58R2rkjc6Berivj39pj48r+018QPDWpQ+ENO8AtpOm2uhtBA22EyRyENLK3lx7EUtgKVJjQYJNf0HwziKdXAUfZ7KKXo1ufjvE1GTxk3Pa7afl0Pl+yvrrSrmC+spWiuLZldHU4IZe9feX7M/gTwt4/+PWlW3inR4dW07WtIn1BraUMYvtUDFC5QEBgXQthsj5jxXpPxh/ZD/Z8+F3w60X4deEfGE3xR+Pviq6tUtbTQJkuLK3jZgZi0UQYiPZkK0jh2OGCqgbH05+x98IE0z4j6z4si8u707wfp8fhq2vITvgudQ8w3OpvC44kjhmfyEkBwwUkVy8YY32WAqu9m1Zd7vY6+FZxqYqGl7P8ABf0j7s0bwtcwWsNpawx2dvAipHEihVRFGAqquAAB0ArtrLQrm1IJk3fhitL7THZReYylz6CrWmaouovJGIyhjAOc5HPvX4HQyuTputbQ/UsVjazi5W90s2ttqM+p2NpC0MdtKXE7ykgqcDZtxxjOc5/CtK/tY7eea1MiXCodu5eVb6U1QAQWAYdwehps7rLI7oixKxyFXoo9Bmuq8FTtbW/4fkfP3m6vM3pb8fzNLwqx0fVIru2hOo6exCyQgb57Qn+JV6tHnuM4Hp3+jlYMoZTkEZFfMOiPZ/21HYX7mCO+BhjmQlXimPMZDDocjA/I9a+gPDV5dXelpHqB3XlozQTnGN0kZxux/tDDfjX65wRjFPD8v9f11/I/POK8O41+b+n/AFt+Z0FFFFfbnygUUUUAFFFFABRRRQB//9D9/KKKKACiiigAooooAKKKKAILkTNbyC2x5pU7cnAz25wf5V8xeJ9L1HRZrbSrryIVffcNFbAt/Fw0krAM7MSSeAB2r6kr5h8U3+r3i3OpRxhIb65ZJZTywihYrDCg99pkc9sivh+OqcXhb638u2n/AAD6rhKo1iUtLefz/wCDbzKlu29c15X4z+LNr4Z8S2fhDS7BtT1S6eNWXfsSPzThQTgktjnGOBzmvQ9PuATtPesj/hBPDJ8WN41Npu1YqFEjMSoIXbuCdA23jNfjcJXR+rU1ShOXto30dvXpfyOwcRycOoYD1GaY6x7MYAUU4DFIw+U1s5trlZwRdjk/E2jeH/Ffh++8J+J7GPUNK1KNoZ4JVDI6OMEEGvjjxh+zh4ku9Dt/B0OqaL468K6eCmn6b4002S/n02M8CO01O2lhvEjX+FHZwBgZr7C1axvlFzLps2y4nZCPNy8aBcA7VyMZXPTvyarxE3USzBHQNn5XGGHPcV2YPPMVhH+4nY7amUYbERXto3Pz68N/sa6fpkwbUINC0C1YFJYfDdhPDdTKeqtqN9Pc3MakcMIPKJHBOK/QrwD4T0TwR4YsvD+gWUVhZ2sYSOGJQqIo6AAf/rJ5PJzXOeKtY07wfoN54n1gSGz09RJL5ab327gMhe+M8+1ej6Zd2moafbahYSLNbXUSSxOvIZHGVI+oNY4vNMXi37TEzbXTt9w54Ghh6Shh4WT3ff5nC/GXwLcfFH4U+K/h3bXn2CbxDp81pHOQSsbuPlLAclcgBgOcZr+cL4g+CPiN8LvH0nhDx5HHp0+kW6R+RbyGSGZGT5JkbADKw5B7YxwQRX9K3ia/1TQpD4lEstxo+n2k3n6daWhubu4nZk8t4mVt3yAMCgX5t2SRivlj9pLQvh/428L+JJ/iX4ejtrXQ7Vzp+qXEsccjs8JfMLo3mR7ZMIY3+83QHNfVcKZ5PCS9m480JdFun5dzkp4L2srrRr7tO5+J3w3+GXxD+MvxEXwT4LMN1Jq0LA/anZILSONfnlkKq2FH0+YkDqRX9J/wv8HH4c/Djwx4BF21+fDunW1ibhhgymBAhfGTgEjgdhgV89/AfSPB3gLwZ4QX4UeF4brTvEKQ/wBo6jbzRiSNTBvM8zvl5/3nybFPyk8AYxX1B4a1xPEmjQayljd6aLgviC+hMFwmxymXjJJG7G5eeVINY8VZ7UxklHl5YR2XW/mZrBeyk7u7/rYxviB4R0Xxr4ZvdC16yiv7K6jKSwSoHSRT1BB/TuDyK/OPxX+xyuoXRNjbaF4pskAWGLxFb3S3sCL0jGpafNDPKijhfPWVgOA2BX6iape2mm6bdajqEqw21tG0ksjHCqiDJJ+gryfwfren+NNBtvFGkpItnfb2i81NjFVYrnbzwcce1fM4TNcZg37TCzaT37fcenSwFDE0XHEQuk9H1Xlc+SPAX7M3ifQdOuvD1lPoHw70PVEMOpReEbO4Gp6hbt96CbVr+WW4SJhwywhNw4Jr7W8I6DoPg3w1p/hDwrYx6bpOmRLFBBEMKqr/AFPUk8k8nmrgt8dBVG3S8uLx4jcF7O5K+Q9suDEYeZBJJkg72GAMDuOtVjc7xeMt9Yne3yKw+VYXDRaoxsdtDCsgGe9aUUMcK7I1Cg+nHNQWyYAq5XNG6VjhrTbdgqJ+AalrOv5xGBGDy38qmcrK5FKDlKyJdOjj1HVI9IlCP9ryIw7FP3qAsu2RclG44OD7g19B+GY9bjjnGtQLDJuGGDhzIAAAzbQBnHB4HTpXybPrGr2wewjtg0MzpLbXYGGtr2MGWAMf7sxTZzxk19m6XeDUdMtNQA2i6hjlwe29Q2P1r9b4EhF0b63X6/5dD4HjJONVbWfz+fz6ry9C9RRRX6AfEhRRRQAUUUUAFFFFAH//0f38ooooAKKKKACiiigAooooAK4rxnpFvcaHNNFZPcyWwd0jhwGJdSrEA4BIBJx3NdrSEZGK58Xho1qcqctmbYes6c1OPQ+IrDUEe9kt41lXyjwZV2N9CuTg+2a7mORZFBHcVifEbUU0TxE0eoWF5bzyyERSSSCWGWMnhkckEe684qeyuFwGP8Vfzji8M8NiJ0G72fofuym6+HhXta69fxMzw/B4ri1nXJtfnjk0+SZP7PjTGUiAOS2ADknHBJ5B7V1lJn5SRzQCcfWpOacnJ3ZFJCkg5qAWaDtSXeqWljeWVhNuM9+7rEqqW+4pdi3ooA6+pA71fJzQ4gpySMTU9DsNY0650rUYhNa3cbxSoejI4Kkfka+QtB8da3+zbNN4D+JdvdXXhGKRjpGtwxPNHHCxyIJwgJUr2/QbcY+16jlijmjMcqh0bqGGQfqDXRQrKKcZq6Z1UMY4pwmrp/1ofA/xI/bh8JaToWo3fw40fUPFlxZxF3nS2lisbcdA80pXcFB7ADP94V4B4c+Ht3+0BBD48+I/iW38aXFwqyx2NvOf7NsA4yI1t4yPnUcMX5z69T+rE9hpnky2C28axOCrxbFCMGGCCuMEH6c18JfE39gT4PeN9Um1rwzc3Hg67uG3SpYqklq7HqRA+NhPojAe1fW8O59l+GbhOm4P+Zav0fb5HpYXGypPnp01LylqeHa/4V139m+2n8Z/DfxFF4WSDMsul3c5bTb4LyYxBISVkbopj5z6da+jPhz+3B4K1nQbK7+IelX/AISvLiMOrSW0s1pOD/HBKq5Kn3Xj1PWsv4W/sEfB/wAC6nFrfiKW48Y30DbohfqiWsZHQ+QmQx/32Ye1fckGlaQEjs5IIpY1ACxMisqgeikEACp4gzzAYmSUKblb7Wz/AFv8xYjGKpL2lSml5R29T5D13xt4i/aYu4fBXw5tbqw8Fb1bVNYmiaITIpz5MIbBOfzJ6gKOfsHSPD+n6JpVpo2mwiG0sokhiQfwogwB+VbkUMUKCKFFjReAqgAD6AVISFUuxAC8kngACvk8RVjO0YxtFdDz6+OckoQVorp+r8zKNiAelTQ2qRjAGKvYB560tc6ikc7ryY1VAFcDoPgy+0LxTq2uR6vNcWWqN5n2STJWNyckqxPTsAAOPpXfk4pjyBFLNwBRK3UKdSSTjF7jJ5khjLtxiuD1bU/JOWOWkPbkgewrQ1nVUiia4k4jToPU1m+BrbWde1oXmnWFzcvEw2tG4ihGeD5kmMqB/s8+lc9GlLE4iFCHXyuehyrDYaeJn087H0L8NdIivNHuJdR0+VIrmKOAi5QL5yRliGCZJGA2OeuARXrkUUcMSQxLtSMBVA6ADgCobG3NraRW5JJRQCWZnOe/zMSx/GrVf0rgMGqFGNNa2R+B4zEutUlUfUKKKK7DlCiiigAooooAKKKKAP/S/fyiiigAooooAKKKKACiiigAooooA5fxfocev6JLYtaW94/VUuQdmfqvIPoRXzFd6Rc6Ey29wIo1zhFjnEoA9B8xbH1r7EIBBBGQa+aPFd5p13qt5b+HdNtra1sjsuLpY1BaQ/wqcdfpz1PSvzvj3LqUqarN+90/r/M+54MzCrCbpJe71/rz8lqcfZ2timqPq7BhdSQrAW3sU2KSwGzO0HJ64z710ysrAbSD9K5hMjrU25lOU61+QRrtaM/Sq2GUndGzdWi3ZhLSPGYJFkBRtpO3+FsdVPcd6tAVzjatdQH95HvX2/xpX8S2sabhE7P/AHRj+ZraNeL6nO8FU6K50e00mcda86uvEmrXLEIVs4h2jHmSkfUjaPyNO8H+IZ9be9k2kWlu4jRiSSzD7xJPWtoLmi5R2Rs8sqqm6j2X6nZ3kcEwxKu7HQ9CPxrmp9MO8mKRgPTNdFK4bnPFRhC/zDoa5pxUisPUdNaGLBpnzDz5XIHYGuns4reBdsCBR39T9TVIRnPNXIjgVdOCjsZ4mo57suHHaub8WHXY9GeTw/bR30yMpltpcAXEB4ljViQAxU/KTxkYPWuV8YeIb/w9qVq4z9iu8qzDgpIOhzRYeLdVgO27Vb2I9GGI5APfHyt+Qrea5EpS2ZtHKavJGrGzTN/QtL1X+wfD6X88ljdWEcRuIYiCkhERQxOW3EqCc8HOQOfXrcHNc1F4s0+QfNDKh9Cq/wBDUx1xJeIEIHq3+FYyrx7nK8HVvrGxavJJo5QVc4GDgcfhWdPcTT8Ofl9BT2leYZY5qs2cHFcVWo3otjuo00t9yumhza7MYbeaONo8E+bMI1P4EjP4V9KfD/wp/wAI5YSSXNraRXVwQS9tvYsnbc7kk/hxXiPhzUIdE1K0l16ygvdJvpBF5zoreTIfUnpjuD25FfVqKqKFQBVAwAOmPav2Dw+y6jGk632+vz/z6NH5pxtj6spqk/g6fL/g7pjqKKK/ST4EKKKKACiiigAooooAKKKKAP/T/fyiiigAooooAKKKKACiiigAooooAxPEl/Lpmg399AjSSxQuUVQWYuRhQAOTk4r5XNxeSQwaS6iGKzHzRjl2uG5kkdhwWzxjtjGa+s9WkuYtMu5LNDJOsTmNRyS+DgD8a+YP7P8A7CVdJuSr3+RJcsDnazDIjB74zknuT7V+Z+IEZ+5Z2jbX79F8936H3nBc4py0vK+n3b/LZepAlkSPmOKnFnEOuTVkMFXcelPByOa/L1TR93KvJ9Th28SeHT4vTwSJXOpvAZ9oXKBRzgt/exzj0ro30yE84zXneseHbbw/4xk8fWrGfUtVNtp8ULj5E3sFdwRz/q1Jx7H1r1eKWOZS0ZyASPxFJQTOqvU5VF027WX39TlNX8MxaxAllJK8NvuzIsR2mQD+Et1A9cda2LXSrPT7KOxsolhhiGFVRgD/AD61s470Fa25ny8l9DmeJm0k3ojnvIlWKVCM5PH0rUhiKxKrdQBU5iBcN6VJgVnGNhVK7kVhGQOTSxg5P1qYgimKf3mMcEU3uTzNopajptnqtq9nfRiWKQYIYZFY+meG4dNtvsKuZ4QcoJPmKD+6CecfWuqxmmFW8wMOmMGtOZ8vLfQuGJnGPKnoYh0S0zny1H5iq2oLp2hadcarfssNraI0kjkE4VRyeOTXTMyqMtwCQPzrjfiDq2maJ4TvbvWbN76wk2wTxRnB8uYhCefTOaxdOK1NqFac5xhq7vpv8i1oWpaR4l0yLVtEnFxazg7XGRyDggg8gjuDVyWzK5INcB8O/CNjofhpR4S1qS40+9vEvYndASsXyiSEj1YKQTgEHtxXq7jKmpnRTRdaooVZKD0v13+ZySz6hFPJpKpHNZakvlywSHYWf+B43PCup+6TwehIHI+ofAF9fX/hLT31SN4b2FDDMsilXDxHYSQfXGfxr51lit9QU6NOVje5cCCU/wDLOY8KCf7r8A+hwa+m/ClxeXPh+ybUUaO6jjEcqt1Dx/KfrnGc96/T/D1S97W6t+uz9N15M/P+NpJqLtZt/puvXZ+aOhooor9PPz4KKKKACiiigAooooAKKKKAP//U/fyiiigAooooAKKKKACiiigAooooAQjPFfNOs2rxagsCQmS912+uXjwMny4WKqo9BwWJ+lfS9eHfEKC08K3i+JbeIy3MsF1GjdWVnCLHGnoCzE8dSc18vxXgVVw/NLaP/A2/L5nvcPYmVOvyx3e3r0v5dfkcTJGCWhchgpxx0yDWVrepXGl6e91Z2pvZVZAIlOCQzAEj6dam+yaha2sljenZdhSG/wBl2GccemawPCtrq6aJbJr64vYAYzznITgNnnJI5r8NqNptWP12lGLXO3dafP8A4Be1T7PdSW7SJue2Yuh/usVK5/IkUnha8Fza3MZPzwXMqH88j9DVWVtrnccc965Oe6v/AA5qU+qWUYmt7tQJY/SRfusP60sFJTcoN6vY9aOB9pT9nDfoel6lqsVgbe34ae7kEcS+p7n6AcmtAzxiQW5YeaVLY74BxmvnO41jVZtUi169YtJEw2gcKo9FH416D4c8RRar4x1UK2R9ltmjH+wC+4D6Ma9PFYLkimte4sdkM6MFK99NfW+34npTswI21J2FU57qC2iM0zbUBAz7scD9TUiSo43Ke5H5HFeapHhuL7FjsajHBzWXq2qppVvFO6GXzp4YAB2MzhM/hnNWEuNwJ7Biv5daTkVGm7XJ1u7drs2O/wDfhBJt/wBgnGfz61XsNRjvTNDwJrZzHIvuOh+hHNeeazrsem+N7GeVsRx2txu9wQpA/wC+gMVx9hreo2+oSatA2JZ2JZTyGHoRXpYfCc9Ny+49rC5FOpBy20TXr2PbNcuRBawqOGlmjUf99ZP8qwb3TdQ1jWrzTtTVbjw9fWIjaMkZWcOeg68qc59hWfZXl1rt+mo3SeVBbDEaA5G89TXYW7kyA9PWuXEWi1Dr1OSrQdGNvtdfL/hjP8KeFrDwdoy6JpskksKSPIDKQWy5yRwAMVvSSKgG44DHGcZxmvNfCXju+1rxlrvhTVLdYG09i1vtBy0SkKd2TyTkMCOxr0yWE3I+zIdpl+QHOME8A5rKC5mlHU5MZTnTm/avXe/qr3M66hS7/tfw40StfWES30bqOSiYPX+JWXkY6Ee9fV9okcdtEkKhECjCjoBjoK+evAulQeJtakTxBCyajosMKeYp2OssUsqsCR1V027lPBB+lfRgAAwOAK/beFMAqVJzW0tvRX381t8j8p4kxntKqg+m/q7Xt5O1/mLRRRX1Z82FFFFABRRRQAUUUUAFFFFAH//V/fyiiigAooooAKKKKACiiigAooooAKxtW0LT9aa0a/QuLKZZ0GeC6g4z6gHn6gVs0VM4KStJFRk07pnzh4s06603Xrw3CkR3Ehkjbsyt7+oPFYaB3BKgkV6H8TrqK1vILjVJBFp9rA0zM3TIbBz+leIax8StG0m+0q1iU3VvqgVlmjI2qrNtBx356jtX4XnGTTWNqwoxdrv8rs/Z8g9vicLTcIXdvlp+tlc5v4geHb/XrOG2sZ/s0kVxHMSSQCEPIOPzHuKyfCep65qlhenxJb+RcQXU0S/LsDxLjaQO45xnvXYPrWvX/jLUvDd7p23ToYfNgulU9QBwW6HJyMdRiqjueQecV8jmGFlQlZu90nofaYepL2apyt0emu+v/DoybqzguYmgYYDdPY1xYt77w7rEGs2CeZJbgrIg/wCWsD43Ae6kAiu8bA5rGvJR559gK9bhupOrUdCTvFpnr4OTlem9UzQ1TxB/wkWnalpVmfLeWDfasRhvNUbgre+4DFdR4W8R2+v6PBqMXyPIP3sZ6xy/xofof0rzNooi/mKuG9Rx/Ko7Y3Gl3b3+nHa0n+tj/hkx0Ps3ofzr3MVw6uV+yevQxxGRwcLU9/6uer+Itb0/SdMfUL/51gIeNByzyj7iqO5J6Vx6+LZ9MtrKPUBvuHBkutvIjL/MVHuDx+HNctIbvU7tdU1YhpU/1MQOUgB9PVz3b8Bx1lZIy+9lyarBcORSTrPUeFyOCX7wqSx3Ou6nJq2oAxGXCRp3SIdAfc9TXU2+n26GPA4TpWNvrftJS8at+dcnEtF0IQdJ2jtY6sbGUYpRdkdRaMqIFUYArfsgzMTjNctaH5gPU1of8JBqtl4z0/wvZ6cXs54TJNckHAOCeD0GCACD1zXzWBoSqt26K58tjE3dR7N9tEbQ0PT4tX/4SD7Iq37ReSZsEMY8g4Pbt16102i2Mmr6rb2MSltzAv7IDyTXB6L8SdG1bVtX0x0NqmkqzNNIRsZUbaxx2wfXrXsPw1u4L7WDe6VKs1jd2pkDr04YAY/HNfVZNk83jadOtF2v+lz5biB4jDUKjqxtK3XzX+TvY9jt9OsrW6nvbeIJNc7fMYfxbBgZ/Cr1FFfuqSWx+Mt33CiiimIKKKKACiiigAooooAKKKKAP//W/fyiiigAooooAKKKKACiiigAooooAKKKKAOS8a+FbHxf4fu9IvIhIZY2VDnBBPbPbOBXxze6PpvhyyTRDZ+Vf6Wsgtmul3NHIxLZDEdNxyMV951n32k6ZqahNRtIrkDp5iBsfmK+dzvIFi7SjNxa+5+qPruHOK54GLpTXNC97XtZ/wDBPzK8MzeK7DXf7S1a6ZYsN5imbzPNLDAG0EjGecn8K9i0nw/4t1q3fVrXTZP7OiBLSMNpYeqKeWA74FfYMPhHwtbyCWHSbVXU5BES5B/KuhCqqhVGAOgHSvLq8F068pTxMrtqysrWPrM38UpV5c1GgovS9+y7JW+/U+DrlFiRmbjH867aX4NeIL7w5ZazZ4XUZULzWrnBKk5TBPRtuAQa+nh4X8OC9/tIabB9pznf5Yzn1+vvW9WXD3BFPBucqsuZvRaWsjy8b4i4hyhLCx5bb31v5eh8caJ8I9Z1i2e1vYLjSb+LJDzIHt5R2AZeVb8wf0rGuPhb4us9Ss9OntGYXRYGSMb1XZknkewyPXPrX3BRX0ryWi0jCn4kZjGUndWd9O3p1/E+Jl+FHjCTEcVi7TMeFOFRB/tyMQCfZc1DefDDxVZ/6Pb6bPfXLcFkTZCn0ZsFvrgD619v0VP9iUSo+JOY3Tdn/Xk/66nyx4a+CtzZW0uteMB5vkRs6WUJ3M5AyAzD+Q/OvK20i/0S9l0rVIjBPGQ4B4yjjIIz+X1r77rI1TQNF1sJ/a1lFdGP7pdQSPoeteZn3C1PF4dUYPla1uPL/EPExqznivfUvla21lt/mfGSadrBs31axtJLi1tWAmZBnbnkcDrjHPpXl3iyXxNqespf6NdNsAXaqy+WY2XrwSPrmv0qs7Cy0+3W0sYEghXoiKFH5CsW88HeFdQkMt5pNtK7HJYxqCT7kV5eD4HWG5ZUanvWs7q6Z7WW+KPsarnOgnul6ed1r+B8Y2mm6brNjLoxsxcajq0aJdNartklcYJO4D+9znp619eeAfBth4L8P2ml2sex441V/m3EdTjPfknJ7muj0/RNH0kH+zLKG1z1MaBSfxFale7knD8cJeUpuUn9y9EfH8RcUzxyVOCcYJ3te93tftsFFFFfRHyYUUUUAFFFFABRRRQAUUUUAFFFFAH/1/38ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/0P38ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/0f38ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/0v38ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/2Q==")),
    ctx
  );

  let mut mint_cap = MintCapability {
    id: object::new(ctx),
    treasury,
    total_minted: 0,
  };

  mint(&mut mint_cap, INITIAL_SUPPLY, ctx.sender(), ctx);

  transfer::public_freeze_object(metadata);
  transfer::transfer(mint_cap, ctx.sender());
}

public fun mint(
  mint_cap: &mut MintCapability,
  amount: u64,
  recipient: address,
  ctx: &mut TxContext
) {
  let coin = mint_internal(mint_cap, amount, ctx);
  transfer::public_transfer(coin, recipient);
}

public fun mint_locked (
  mint_cap: &mut MintCapability,
  amount: u64,
  recipient: address,
  duration: u64,
  clock: &Clock,
  ctx: &mut TxContext
) {
  let coin = mint_internal(mint_cap, amount, ctx);
  let start_date= clock.timestamp_ms();
  let unlock_date = start_date + duration;

  let locker = Locker {
    id: object::new(ctx),
    unlock_date,
    balance: coin::into_balance(coin)
  };

  transfer::public_transfer(locker, recipient);
}

entry fun withdraw_locked(locker: Locker, clock: &Clock, ctx: &mut TxContext): u64 {
  let Locker {id, mut balance, unlock_date} = locker;
  assert!(clock.timestamp_ms() >= unlock_date, ETokenLocked);

  let locked_balance_value = balance.value();

  transfer::public_transfer(
    coin::take(& mut balance, locked_balance_value, ctx),
    ctx.sender()
  );

  balance.destroy_zero();
  object::delete(id);

  locked_balance_value
}

fun mint_internal(
  mint_cap: &mut MintCapability,
  amount: u64,
  ctx: &mut TxContext
) : coin::Coin<COCO> {
  assert!(amount > 0, EInvalidAmount);
  assert!(mint_cap.total_minted + amount <= TOTAL_SUPPLY, ESupplyExceeded);

  let treasury = &mut mint_cap.treasury;

  let coin = coin::mint(treasury, amount, ctx);
  mint_cap.total_minted = mint_cap.total_minted + amount;
  coin
}

#[test_only]
use sui::test_scenario;
#[test_only]
use sui::clock;

#[test]
fun test_init() {
  let publisher = @0x11;

  let mut scenario = test_scenario::begin(publisher); {
    let otw = COCO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mint_cap = scenario.take_from_sender<MintCapability>();
    let coco_coin = scenario.take_from_sender<coin::Coin<COCO>>();

    assert!(mint_cap.total_minted == INITIAL_SUPPLY, EInvalidAmount);
    assert!(coco_coin.balance().value() == INITIAL_SUPPLY, ESupplyExceeded);

    scenario.return_to_sender(coco_coin);
    scenario.return_to_sender(mint_cap);
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();

    mint(
      &mut mint_cap,
      100_000_000_000_000_000,
      scenario.ctx().sender(),
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);

    scenario.return_to_sender(mint_cap);
  };

  scenario.end();
}

#[test]
fun test_lock_tokens() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher); {
    let otw = COCO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher); {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      100_000_000_000_000_000,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);
    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob); {
    let locker = scenario.take_from_sender<Locker>();
    let duration = 5000;
    let mut test_clock = clock::create_for_testing(scenario.ctx());
    test_clock.set_for_testing(duration);

    let amount = withdraw_locked(locker, &test_clock, scenario.ctx());

    assert!(amount == 100_000_000_000_000_000, EInvalidAmount);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob); {
    let coin = scenario.take_from_sender<coin::Coin<COCO>>();
    assert!(coin.balance().value() == 100_000_000_000_000_000, EInvalidAmount);
    scenario.return_to_sender(coin);
  };
  scenario.end();
}

#[test]
#[expected_failure(abort_code = ESupplyExceeded)]
fun test_lock_overflow() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher); {
    let otw = COCO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher); {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      100_000_000_000_000_001,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );
    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.end();
}

#[test]
#[expected_failure(abort_code = ESupplyExceeded)]
fun test_mint_overflow() {
  let publisher = @0x11;

  let mut scenario = test_scenario::begin(publisher); {
    let otw = COCO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher); {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();

    mint(
      &mut mint_cap,
      100_000_000_000_000_001,
      scenario.ctx().sender(),
      scenario.ctx()
    );
    scenario.return_to_sender(mint_cap);
  };

  scenario.end();
}

#[test]
#[expected_failure(abort_code = ETokenLocked)]
fun test_withdraw_locked_before_unlock() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher); {
    let otw = COCO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher); {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      100_000_000_000_000_000,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);
    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob); {
    let locker = scenario.take_from_sender<Locker>();
    let duration = 4000;
    let mut test_clock = clock::create_for_testing(scenario.ctx());
    test_clock.set_for_testing(duration);

    withdraw_locked(locker, &test_clock, scenario.ctx());

    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob); {
    let coin = scenario.take_from_sender<coin::Coin<COCO>>();
    assert!(coin.balance().value() == 100_000_000_000_000_000, EInvalidAmount);
    scenario.return_to_sender(coin);
  };
  scenario.end();
}
